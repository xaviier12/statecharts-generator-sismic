package be.ac.umons.bol.generator.sismic

import org.yakindu.sct.model.sgraph.Statechart
import be.ac.umons.bol.generator.sismic.specification.SpecificationRoot
import java.util.ArrayList

/**
 * Français :
 * Cette classe permet de générer un modèle important l'interpréteur Sismic pour commencer l'interprétation avec Sismic du statechart
 * généré par ce générateur.
 * 
 * English :
 * This class allow to generate a template that import the Sismic interpreter to begin the interpretation with Sismic
 * of statechart generated by this generator.
 */
abstract class SismicInterpreter {
	
	/**
	 * Create the content of the template of the Python file created by this generator
	 * 
	 * @param sc : the object of the statechart in Yakindu
	 * @param specificationRoot : the specification extract into sgraph:Statechart tag
	 * 
	 * @return the template
	 */
	static def content(Statechart sc, SpecificationRoot specificationRoot) '''
		from sismic.io import import_from_yaml
		from sismic.interpreter import Interpreter
		from sismic.model import MacroStep
		
		«IF specificationRoot !== null && specificationRoot.listInterfaces !== null && !specificationRoot.listInterfaces.empty»
			«specificationRoot.generatePython()»
			«IF specificationRoot.context.empty»
				context = {}
			«ELSE»
				context = «makeContext(specificationRoot.context)»
			«ENDIF»
		«ENDIF»
		
		def set_up() -> Interpreter:
		    # Load statechart from yaml file
		    «sc.name» = import_from_yaml(filepath='«sc.name».yaml')
		
		    # Create an interpreter for this statechart
		    return Interpreter(«sc.name», initial_context=context)
		
		
		def display_attributes(step: MacroStep) -> None:
		    for attribute in [
		        "event",
		        "transitions",
		        "entered_states",
		        "exited_states",
		        "sent_events",
		    ]:
		        print("{}: {}".format(attribute, getattr(step, attribute)))
		
		
		def next_step(interpreter: Interpreter) -> MacroStep:
		    print("Before:", interpreter.configuration)
		
		    step = interpreter.execute_once()
		
		    print("After:", interpreter.configuration)
		    return step
		
		if __name__ == "__main__":
		    interpreter = set_up()
		    step = next_step(interpreter)
		    display_attributes(step)
	'''
	
	/**
	 * Create the template for the context of the Sismic interpreter
	 * 
	 * @param context : the data for the context
	 * 
	 * @return the template for the context of Sismic interpreter
	 */
	static private def makeContext(ArrayList<String> context) '''
		{
			«FOR name : context»
				"«name»": «name»,
			«ENDFOR»
		}
	'''
}