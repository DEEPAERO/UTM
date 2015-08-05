// UTMmain.cpp : Defines the entry point for the console application.
//

/******************************************************************************
| This contains the code used for the NASA grant NNX14AI10G entitled    		  |
| "Typecasting agents for managing human-system interactions in the NAS"      |
|																			                                        |
| Redistributables are also included, as well as past experimental data.	    |
|																			                                        |
| Create a new stat_results file for output if desired.						            |
|																			                                        |
******************************************************************************/

// Standard includes
#include <stdio.h>
#include <stdlib.h>
#include <string>

// for memory leak detection
//#include "../nvwa-1.0/nvwa/debug_new.h"

// Project-specific includes
#include "../libraries/Simulation/SimTypeNE.h"
#include "../libraries/Domains/ATFMSectorDomain/ATFMSectorDomain.h"





void program(int calls, MultiagentTypeNE::TypeHandling sim_mode, std::string rwd_name, std::string conflict_name){
	//srand(time(NULL));
	ATFMSectorDomain* domain = new ATFMSectorDomain(true);

	// FOR DEBUGGING
	

	NeuroEvoParameters* NE_params = new NeuroEvoParameters(domain->n_state_elements,domain->n_control_elements);
	//new MultiagentTypeNE(n_agents,NE_params,type_mode,n_types);
	MultiagentTypeNE* MAS = new MultiagentTypeNE(domain->n_agents, NE_params, sim_mode,domain->n_types);
	// END FOR DEBUGGING

	SimTypeNE sim(domain, MAS, sim_mode); // FOR DEBUGGING
	sim.runExperiment();

	sim.outputRewardLog(rwd_name+to_string(calls)+".txt");
	sim.outputMetricLog(conflict_name+to_string(calls)+".txt");
	delete ((ATFMSectorDomain*)domain);

}

void metaprog(){
std::string rwd_names[MultiagentTypeNE::TypeHandling::NMODES] = {
	"stat_results/blind_reward-",
	"stat_results/weighted_reward-",
	"stat_results/crossweighted_reward-",
	"stat_results/multimind_reward-",
};

std::string conflict_names[MultiagentTypeNE::TypeHandling::NMODES] = {
	"stat_results/blind_conflict-",
	"stat_results/weighted_conflict-",
	"stat_results/crossweighted_conflict-",
	"stat_results/multimind_conflict-",
};
/**/
int r=0;
//int i=0;*/
	//for (int r=0; r<5; r++){
		//printf("************* RUN %i STARTING ***********\n",r);
//#pragma omp parallel for
		for (int i=0; i<MultiagentTypeNE::NMODES; i++){
			//if (i==MultiagentTypeNE::WEIGHTED || i==MultiagentTypeNE::MULTIMIND || i==MultiagentTypeNE::BLIND) continue;
			//if (i==MultiagentTypeNE::BLIND) continue;
			printf("mode type %i started. ", i);
			program(r,MultiagentTypeNE::TypeHandling(i), rwd_names[i], conflict_names[i]);
		}
	//}
}

int main(int argc, char** argv)
{
	metaprog();
	system("pause");
	return 0;
}

