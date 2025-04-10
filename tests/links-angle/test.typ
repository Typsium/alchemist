#import "../../lib.typ": *

#for i in range(0, 360, step: 10) {
	skeletize({
		fragment("ABCD")
		single(absolute: i)
		fragment("EFGH")
	})
}