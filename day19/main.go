package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"

	"golang.org/x/exp/maps"
	"golang.org/x/exp/slices"
)

type beacon struct {
	x, y, z int
}

type v3 struct {
	x, y, z int
	rot     int
}

type beaconPair struct {
	a, b int
}
type beaconPairs []beaconPair

type scanner struct {
	id      int
	beacons []beacon
}

func rotate_x(b beacon) beacon {
	return beacon{x: b.x, y: -b.z, z: b.y}
}

func neg_rotate_x(b beacon) beacon {
	return beacon{x: b.x, y: b.z, z: -b.y}
}

func rotate_y(b beacon) beacon {
	return beacon{x: b.z, y: b.y, z: -b.x}
}

func rotate_z(b beacon) beacon {
	return beacon{x: b.y, y: b.x, z: b.z}
}

func neg_rotate_z(b beacon) beacon {
	return beacon{x: b.y, y: -b.x, z: b.z}
}

func full_rotate_y(b beacon) []beacon {
	r := make([]beacon, 0, 4)
	for i := 0; i < 4; i++ {
		r = append(r, b)
		b = rotate_y(b)
	}
	return r
}

func affinities(b beacon) []beacon {
	var r []beacon

	// 6 main transformations
	// 1' identity
	r = full_rotate_y(b)
	// 2' Rx
	r = append(r, full_rotate_y(rotate_x(b))...)
	// 3' Rz
	r = append(r, full_rotate_y(rotate_z(b))...)
	// 4' -Rz
	r = append(r, full_rotate_y(neg_rotate_z(b))...)
	// 5' Rx * Rx
	r = append(r, full_rotate_y(rotate_x(rotate_x(b)))...)
	// 6' -Rx
	r = append(r, full_rotate_y(neg_rotate_x(b))...)

	return r
}

func dist(s scanner) map[float64]beaconPairs {
	m := make(map[float64]beaconPairs)
	nBeacons := len(s.beacons)

	for i := 0; i < nBeacons; i += 1 {
		for j := i; j < nBeacons; j += 1 {
			if i == j {
				continue
			}
			dx := float64(s.beacons[j].x - s.beacons[i].x)
			dy := float64(s.beacons[j].y - s.beacons[i].y)
			dz := float64(s.beacons[j].z - s.beacons[i].z)

			dist := math.Sqrt(dx*dx + dy*dy + dz*dz)
			pair := beaconPair{a: i, b: j}
			if _, p := m[dist]; p == false {
				m[dist] = beaconPairs{pair}
			} else {
				m[dist] = append(m[dist], pair)
			}
		}
	}

	return m
}

func main() {
	scanners := loadInput("mini.txt")
	part1(scanners)
}

func part1(scanners []scanner) {
	trMap := make(map[int][]int)

	for i := 0; i < len(scanners); i++ {
		for j := i + 1; j < len(scanners); j++ {
			n := countOverlap(scanners[i], scanners[j])
			if n >= 12 {
				addRel(i, j, trMap)
			}
		}
	}

	points := make(map[beacon]bool)
	for i := 1; i < len(scanners); i++ {
		path, ok := findPath(i, trMap)
		if !ok {
			panic("cannot find a path")
		}

		fmt.Printf("found: %v\n", path)

		si := scanners[i]
		for idx := 1; idx < len(path); idx++ {
			to := path[idx]
			si = convert(scanners[to], si)
		}

		for _, v := range si.beacons {
			points[v] = true
		}
	}

	fmt.Printf("#points: %d\n", len(points))
}

func addRel(i int, j int, trMap map[int][]int) {
	if v, ok := trMap[i]; ok {
		v = append(v, j)
		trMap[i] = v
	} else {
		trMap[i] = []int{j}
	}

	if v, ok := trMap[j]; ok {
		v = append(v, i)
		trMap[j] = v
	} else {
		trMap[j] = []int{i}
	}
}

func findPath(id int, trMap map[int][]int) ([]int, bool) {
	path := []int{id}
	return findWithPath(id, path, trMap)
}

func findWithPath(id int, path []int, trMap map[int][]int) ([]int, bool) {
	if ns, ok := trMap[id]; ok {
		for _, n := range ns {
			nPath := append(path, n)
			if n == 0 {
				return nPath, true
			}
			if slices.Contains(path, n) {
				continue
			}
			if rPath, complete := findWithPath(n, nPath, trMap); complete {
				return rPath, complete
			}
		}
	}
	return path, false
}

func countOverlap(s0 scanner, si scanner) int {
	d0 := dist(s0)
	d1 := dist(si)

	maybe := make(map[beaconPair]int)

	for k, ps0 := range d0 {
		if ps1, ok := d1[k]; ok {
			//fmt.Printf("ps0: %v, ps1: %v\n", ps0, ps1)
			for _, e1 := range ps0 {
				for _, e2 := range ps1 {
					maybe[beaconPair{a: e1.a, b: e2.a}] += 1
					maybe[beaconPair{a: e1.a, b: e2.b}] += 1

					maybe[beaconPair{a: e1.b, b: e2.a}] += 1
					maybe[beaconPair{a: e1.b, b: e2.b}] += 1
				}
			}
		}
	}

	// take only those > 1
	for k, v := range maybe {
		if v == 1 {
			delete(maybe, k)
		}
	}

	return len(maybe)
}

func convert(s0 scanner, s1 scanner) scanner {
	d0 := dist(s0)
	d1 := dist(s1)

	maybe := make(map[beaconPair]int)

	for k, ps0 := range d0 {
		if ps1, ok := d1[k]; ok {
			//fmt.Printf("ps0: %v, ps1: %v\n", ps0, ps1)
			for _, e1 := range ps0 {
				for _, e2 := range ps1 {
					maybe[beaconPair{a: e1.a, b: e2.a}] += 1
					maybe[beaconPair{a: e1.a, b: e2.b}] += 1

					maybe[beaconPair{a: e1.b, b: e2.a}] += 1
					maybe[beaconPair{a: e1.b, b: e2.b}] += 1
				}
			}
		}
	}

	// take the only > 1
	for k, v := range maybe {
		if v == 1 {
			delete(maybe, k)
		}
	}

	maybeV := make(map[v3]int)
	for k := range maybe {
		a := s0.beacons[k.a]
		bs := affinities(s1.beacons[k.b])
		for rotIdx, b := range bs {
			v := v3{x: a.x - b.x, y: a.y - b.y, z: a.z - b.z, rot: rotIdx}
			maybeV[v] += 1
		}
	}

	// take the only > 1
	for k, v := range maybeV {
		if v == 1 {
			delete(maybeV, k)
		}
	}

	vo := maps.Keys(maybeV)[0]

	// convert s1 relative to s0
	for i, v := range s1.beacons {
		b := affinities(v)[vo.rot]
		s1.beacons[i] = beacon{x: b.x + vo.x, y: b.y + vo.y, z: b.z + vo.z}
	}

	return s1
}

// helpers

func loadInput(fileName string) []scanner {
	var scanners []scanner
	var beacons []beacon

	content, err := os.ReadFile(fileName)
	if err != nil {
		panic(err)
	}

	idx := 0
	lines := strings.Split(string(content), "\n")
	for _, l := range lines {
		if strings.HasPrefix(l, "---") {
			if idx == 0 {
				idx = 1
				continue
			}

			scanners = append(scanners, scanner{id: idx, beacons: beacons})
			beacons = []beacon{}
			idx = idx + 1
			continue
		}

		if l == "" {
			continue
		}

		var b beacon
		tks := strings.Split(l, ",")
		if len(tks) != 3 {
			panic("invalid beacon")
		}

		b.x, err = strconv.Atoi(tks[0])
		if err != nil {
			panic(err)
		}
		b.y, err = strconv.Atoi(tks[1])
		if err != nil {
			panic(err)
		}
		b.z, err = strconv.Atoi(tks[2])
		if err != nil {
			panic(err)
		}

		beacons = append(beacons, b)
	}

	scanners = append(scanners, scanner{id: idx, beacons: beacons})
	return scanners
}
