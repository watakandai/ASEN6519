using ASEN6519
using Test


@test 1 == 1

@testset "ASEN6519" begin
    n = Node("hello")
    @test n != Nothing()

    e = Edge("source", "target")
    @test e != Nothing()

    h = HybridSystem()
    @test h != Nothing()
end
