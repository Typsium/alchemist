#import "../../lib.typ": *

#for i in range(0, 360, step: 10) {
	skeletize({
		molecule("ABCD")
		single(absolute: i)
		molecule("EFGH")
	})
}