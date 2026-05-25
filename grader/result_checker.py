import sys

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print("Usage: python result_checker.py <target assignment>")
    exit(1)

  target_assignment = sys.argv[1]
  with open("grader_result.txt", "r") as f:
    # Read all lines
    lines = f.read()

    # Check if the target assignment is in the result
    if not f'{target_assignment} test passed.' in lines:
      print(f"Test failed for {target_assignment}")
      exit(1)

    print("All tests passed!")