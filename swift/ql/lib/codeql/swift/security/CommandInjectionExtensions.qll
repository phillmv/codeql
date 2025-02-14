/**
 * Provides classes and predicates for reasoning about system
 * commands built from user-controlled sources (that is, command injection
 * vulnerabilities).
 */

import swift
import codeql.swift.dataflow.DataFlow
import codeql.swift.dataflow.ExternalFlow

/**
 * A dataflow sink for command injection vulnerabilities.
 */
abstract class CommandInjectionSink extends DataFlow::Node { }

/**
 * A barrier for command injection vulnerabilities.
 */
abstract class CommandInjectionBarrier extends DataFlow::Node { }

/**
 * A unit class for adding additional flow steps.
 */
class CommandInjectionAdditionalFlowStep extends Unit {
  /**
   * Holds if the step from `node1` to `node2` should be considered a flow
   * step for paths related to command injection vulnerabilities.
   */
  abstract predicate step(DataFlow::Node nodeFrom, DataFlow::Node nodeTo);
}

/**
 * An additional taint step for command injection vulnerabilities.
 */
private class CommandInjectionArrayAdditionalFlowStep extends CommandInjectionAdditionalFlowStep {
  override predicate step(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    // needed until we have proper content flow through arrays.
    exists(ArrayExpr arr |
      nodeFrom.asExpr() = arr.getAnElement() and
      nodeTo.asExpr() = arr
    )
  }
}

/**
 * A sink defined in a CSV model.
 */
private class DefaultCommandInjectionSink extends CommandInjectionSink {
  DefaultCommandInjectionSink() { sinkNode(this, "command-injection") }
}

private class CommandInjectionSinks extends SinkModelCsv {
  override predicate row(string row) {
    row =
      [
        ";Process;true;run(_:arguments:terminationHandler:);;;Argument[0..1];command-injection",
        ";Process;true;launchedProcess(launchPath:arguments:);;;Argument[0..1];command-injection",
        ";Process;true;arguments;;;PostUpdate;command-injection",
        ";Process;true;currentDirectory;;;PostUpdate;command-injection",
        ";Process;true;environment;;;PostUpdate;command-injection",
        ";Process;true;executableURL;;;PostUpdate;command-injection",
        ";Process;true;standardError;;;PostUpdate;command-injection",
        ";Process;true;standardInput;;;PostUpdate;command-injection",
        ";Process;true;standardOutput;;;PostUpdate;command-injection",
        ";Process;true;currentDirectoryPath;;;PostUpdate;command-injection",
        ";Process;true;launchPath;;;PostUpdate;command-injection",
        ";NSUserScriptTask;true;init(url:);;;Argument[0];command-injection",
        ";NSUserUnixTask;true;execute(withArguments:completionHandler:);;;Argument[0];command-injection",
      ]
  }
}
