use oc

import io/FileReader
import structs/[Stack, List, HashMap], io/File

import frontend/[Frontend, ParsingPool]

import ast/[Module, FuncDecl, Call, Statement, Type, Expression,
    Var, Access, StringLit, NumberLit, Import, Node, Return, CoverDecl]
import middle/Resolver

/**
 * This class uses nagaqueen callbacks to create an oc AST from a .ooc file.
 * 
 * Since nagaqueen is rock's parser, it means that with oc-nagaqueen, oc can parse
 * the same things at rock - at least on the surface. Some parts of the syntax
 * may be unimplemented and/or behave differently. In that case, a compiler error is thrown.
 */ 
AstBuilder: class {

    module: Module
    pool: ParsingPool
    stack := Stack<Object> new()
    
    doParse: func (=module, path: String, =pool) {
        stack push(module)

        reader := FileReader new(path)
    }

    /*
     * Stack handling functions
     */

    /**
     * Removes the head of the stack and return it
     */
    pop: func <T> (T: Class) -> T {
        v := stack pop()
        if(!v instanceOf?(T)) Exception new("Expected " + T name + ", pop'd " + v class name) throw()
        v
    }

    /**
     * Returns the head of the stack without removing it
     */
    peek: func <T> (T: Class) -> T {
        v := stack peek()
        if(!v instanceOf?(T)) Exception new("Expected " + T name + ", peek'd " + v class name) throw()
        v
    }

    /**
     * Return a String representation of the current state of the stack
     */
    stackString: func -> String {
        b := Buffer new()
        stack each(|el|
            b append(match el {
                case n: Node => n toString()
                case         => el class name
            }). append(" :: ")
        )
        b toString()
    }
}

/**
 * This is Magog's implementation of Frontend. It just uses AstBuilder under
 * the hood
 */
magog_Frontend: class extends Frontend {
    
    builder := AstBuilder new()
    
    init: func (=pool) {}

    parse: func (path: String) {
        try {
            // FIXME: this is quite a horrible way to strip '.ooc' from files
            module = Module new(path substring(0, -5))
            builder doParse(module, path, pool)
        } catch (e: Exception) {
            e print()
        }
    }
    
}

magog_FrontendFactory: class extends FrontendFactory {
 
    pool: ParsingPool
 
    init: func (=pool) {}
    
    create: func -> Frontend {
        magog_Frontend new(pool)
    }
    
}
