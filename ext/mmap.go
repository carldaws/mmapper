package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"bytes"
	"os"
	"sync"
	"syscall"
)

// Mmapper holds the mmap data for a file
type Mmapper struct {
	mmapData []byte
	fileSize int
}

// Store instances
var (
	mu        sync.Mutex
	mmappers  = make(map[int]*Mmapper)
	nextID    = 1
)

// mmapFile maps a file into memory.
func mmapFile(filename string) (*Mmapper, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	fi, err := file.Stat()
	if err != nil {
		return nil, err
	}

	size := fi.Size()
	if size == 0 {
		return nil, os.ErrInvalid
	}

	data, err := syscall.Mmap(int(file.Fd()), 0, int(size), syscall.PROT_READ, syscall.MAP_SHARED)
	if err != nil {
		return nil, err
	}

	return &Mmapper{mmapData: data, fileSize: int(size)}, nil
}

// findLineStart moves backward to find the start of a line.
func findLineStart(data []byte, pos int) int {
	for pos > 0 && data[pos-1] != '\n' {
		pos--
	}
	return pos
}

// readLine reads a full line starting from a given position.
func readLine(data []byte, start int, fileSize int) string {
	end := start
	for end < fileSize && data[end] != '\n' {
		end++
	}
	return string(data[start:end])
}

// binarySearchPrefix performs a binary search for a prefix.
func binarySearchPrefix(m *Mmapper, prefix string) string {
	low, high := 0, m.fileSize-1
	var match string

	for low <= high {
		mid := (low + high) / 2
		mid = findLineStart(m.mmapData, mid)

		line := readLine(m.mmapData, mid, m.fileSize)
		if bytes.HasPrefix([]byte(line), []byte(prefix)) {
			match = line
			high = mid - 1
		} else if line < prefix {
			low = mid + len(line) + 1
		} else {
			high = mid - 1
		}
	}
	return match
}

//export CreateMmapper
func CreateMmapper(filename *C.char) C.int {
	m, err := mmapFile(C.GoString(filename))
	if err != nil {
		return -1 // Error case
	}

	mu.Lock()
	id := nextID
	nextID++
	mmappers[id] = m
	mu.Unlock()

	return C.int(id)
}

//export FindMatchingLine
func FindMatchingLine(mmapperID C.int, prefix *C.char) *C.char {
	mu.Lock()
	m, exists := mmappers[int(mmapperID)]
	mu.Unlock()

	if !exists {
		return nil
	}

	match := binarySearchPrefix(m, C.GoString(prefix))
	if match == "" {
		return nil
	}

	return C.CString(match)
}

func main() {}
