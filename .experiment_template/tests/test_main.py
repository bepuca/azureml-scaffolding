from main import get_the_ultimate_answer


def test_get_the_ultimate_answer():
    expected_answer = 42

    answer = get_the_ultimate_answer()

    assert answer == expected_answer
