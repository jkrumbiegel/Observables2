using Observables2
using Test

@testset "Basics" begin
    xx = Observable([1, 2, 3])

    yy = observe!(xx, 2) do xs, factor
        xs .* factor
    end

    zz = observe!(yy) do y
        y ./ 10
    end

    xx[!] = [2, 3, 4]
    @test xx[] == [2, 3, 4]
    @test yy[] == [4, 6, 8]
    @test zz[] == [0.4, 0.6, 0.8]

    # check that all three observables are disabled through xx
    @test disable!(xx) == 3
end

@testset "Printing" begin
    xx = Observable([1, 2, 3])
    yy = observe!(identity, xx)

    @test string(xx) == """
        Observable{Array{Int64,1}} with 0 observable, 0 ordinary inputs, and 1 listeners.
        Value: [1, 2, 3]"""

    @test string(yy) == """
        Observable{Array{Int64,1}} with 1 observable, 0 ordinary inputs, and 0 listeners.
        Value: [1, 2, 3]"""

    stop_observing!(yy)

    @test string(xx) == """
        Observable{Array{Int64,1}} with 0 observable, 0 ordinary inputs, and 0 listeners.
        Value: [1, 2, 3]"""

    @test string(yy) == """
        Observable{Array{Int64,1}} with 0 observable, 1 ordinary inputs, and 0 listeners.
        Value: [1, 2, 3]"""
end

@testset "Typing" begin
    xx = Observable([1, 2, 3])
    @test typeof(xx) == Observable{Array{Int,1}}
    xx = Observable([1, 2, 3], type = Any)
    @test typeof(xx) == Observable{Any}
end


@testset "on onany off" begin
    x = Observable(1)
    y = Observable(2)

    testref = Ref(0)
    z = onany(x, y) do x, y
        testref[] = x + y
    end

    @test z isa Observable{NoValue}
    @test testref[] == 0
    x[] = 3
    @test testref[] == 5

    @test n_observable_inputs(z) == 2
    off(x, z)
    @test n_observable_inputs(z) == 1

    x[] = 4
    @test testref[] == 5
    y[] = 5
    @test testref[] == 8

end