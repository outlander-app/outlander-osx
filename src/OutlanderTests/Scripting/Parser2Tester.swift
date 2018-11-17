

public final class Expression {
    public enum Symbol {
        case variable(String)
        case function(String, arity: Int)
    }
}
