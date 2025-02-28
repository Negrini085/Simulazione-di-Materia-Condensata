import std/unittest
import ../src/pcg




suite "PCG":

    setup:
        var 
            randSet: RandomSetUp = (42.uint64, 54.uint64)
            gen = newPCG(randSet)

    test "newPCG proc":
        # Checking PCG constructor
        
        check gen.state == uint64(1753877967969059832)
        check gen.incr == uint64(109)
    

    test "random proc":
        # Checking PCG rand procedure
        var test = [uint32(2707161783), uint32(2068313097), uint32(3122475824), uint32(2211639955), uint32(3215226955), uint32(3421331566)]

        for i in test:
            check gen.random == i


    test "rand proc (0, 1)":
        # Checking PCG rand procedure

        for i in 0..100000000:
            check gen.rand <= 1


    test "rand proc (a, b)":
        # Checking PCG rand procedure
        var appo: float32

        for i in 0..100000000:
            appo = gen.rand(2, 4)
            check appo <= 4 and appo >= 2
