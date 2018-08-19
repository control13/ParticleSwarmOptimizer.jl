var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#ParticleSwarmOptimizer-1",
    "page": "Home",
    "title": "ParticleSwarmOptimizer",
    "category": "section",
    "text": "The ParticleSwarmOptimizer (PSO) is an optimization algorithm based on the idea of bird flocking or fish schooling. The PSO can also be used for nonlinear and noncontinous functions.(Image: PSO-Example)"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Pkg.clone(\"git@github.com:control13/ParticleSwarmOptimizer.jl.git\")\nPkg.build(\"ParticleSwarmOptimizer\")"
},

{
    "location": "index.html#simple-ussage-1",
    "page": "Home",
    "title": "simple ussage",
    "category": "section",
    "text": "import ParticleSwarmOptimizer\nconst pso = ParticleSwarmOptimizer\nobjective = pso.Objective(pso.TestFunctions.sphere, 2, (-10.0, 10.0))\nneighbours = pso.LocalNeighbourhood(20)\noptimizer = pso.PSO(objective, neighbours)\npso.optimize!(optimizer, 10)"
},

{
    "location": "parameter.html#",
    "page": "Parameter",
    "title": "Parameter",
    "category": "page",
    "text": ""
},

{
    "location": "parameter.html#Parameter-1",
    "page": "Parameter",
    "title": "Parameter",
    "category": "section",
    "text": "The behavior of the PSO can be modified by three parameters w c_1 c_2."
},

{
    "location": "updatefunction.html#",
    "page": "Update function",
    "title": "Update function",
    "category": "page",
    "text": ""
},

{
    "location": "updatefunction.html#Parameterupdate-1",
    "page": "Update function",
    "title": "Parameterupdate",
    "category": "section",
    "text": ""
},

{
    "location": "neighbourhood.html#",
    "page": "Neighbourhood",
    "title": "Neighbourhood",
    "category": "page",
    "text": ""
},

{
    "location": "neighbourhood.html#Neighbourhood-1",
    "page": "Neighbourhood",
    "title": "Neighbourhood",
    "category": "section",
    "text": ""
},

{
    "location": "own_updatefunction.html#",
    "page": "Update function",
    "title": "Update function",
    "category": "page",
    "text": ""
},

{
    "location": "own_updatefunction.html#Write-your-own-updatefunction-1",
    "page": "Update function",
    "title": "Write your own updatefunction",
    "category": "section",
    "text": ""
},

{
    "location": "own_neighbourhood.html#",
    "page": "Neighbourhood",
    "title": "Neighbourhood",
    "category": "page",
    "text": ""
},

{
    "location": "own_neighbourhood.html#Write-your-own-neighborhood-1",
    "page": "Neighbourhood",
    "title": "Write your own neighborhood",
    "category": "section",
    "text": ""
},

]}
