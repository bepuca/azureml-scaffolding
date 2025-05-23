# Library file for functions related to runs

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo >&2 "This script must be sourced, not executed."
    exit 1
fi

run::prepare() {
    if [ $# -eq 0 ]; then
        echo>&2 "GROUP not provided."
        echo>&2 "Usage: $0 GROUP"
        exit 1
    fi

    bin/chkenv "RUNS_PATH"
    local run_group=$1  # usually package or pipeline name

    local run_name
    run_name=$(run::name)
    # add timestamp locally so runs are sorted chronologically
    local local_run_name
    local_run_name="$(date +%Y%m%d_%H%M%S)_$run_name"
    local run_dir="$RUNS_PATH/$run_group/$local_run_name"
    echo "$run_name" "$run_dir"
}

run::local() {
    if [ $# -eq 0 ]; then
        echo>&2 "PACKAGE not provided."
        echo>&2 "Usage: ${FUNCNAME[0]} PACKAGE"
        exit 1
    fi

    local package=$1
    uv run \
        --with-requirements "../environment/requirements.txt" \
        --isolated \
        --no-project \
        -m "${package//-/_}"
}


# Create a random and memorable name for a run
run::name() {
    # Adjectives and nouns copied from Moby project:
    #    https://github.com/moby/moby/blob/master/pkg/namesgenerator/names-generator.go
    local adjectives=(
        "admiring" "adoring" "affectionate" "agitated" "amazing"
        "angry" "awesome" "beautiful" "blissful" "bold" "boring"
        "brave" "busy" "charming" "clever" "compassionate" "competent"
        "condescending" "confident" "cool" "cranky" "crazy" "dazzling"
        "determined" "distracted" "dreamy" "eager" "ecstatic" "elastic"
        "elated" "elegant" "eloquent" "epic" "exciting" "fervent"
        "festive" "flamboyant" "focused" "friendly" "frosty" "funny"
        "gallant" "gifted" "goofy" "gracious" "great" "happy"
        "hardcore" "heuristic" "hopeful" "hungry" "infallible" "inspiring"
        "intelligent" "interesting" "jolly" "jovial" "keen" "kind"
        "laughing" "loving" "lucid" "magical" "modest" "musing"
        "mystifying" "naughty" "nervous" "nice" "nifty" "nostalgic"
        "objective" "optimistic" "peaceful" "pedantic" "pensive" "practical"
        "priceless" "quirky" "quizzical" "recursing" "relaxed" "reverent"
        "romantic" "sad" "serene" "sharp" "silly" "sleepy"
        "stoic" "strange" "stupefied" "suspicious" "sweet" "tender"
        "thirsty" "trusting" "unruffled" "upbeat" "vibrant" "vigilant"
        "vigorous" "wizardly" "wonderful" "xenodochial" "youthful" "zealous"
        "zen"
    )

    local nouns=(
        "archimedes" "ardinghelli" "aryabhata" "austin" "babbage"
        "banach" "banzai" "bardeen" "bartik" "bassi"
        "beaver" "bell" "benz" "bhabha" "bhaskara"
        "black" "blackburn" "blackwell" "bohr" "booth"
        "borg" "bose" "bouman" "boyd" "brahmagupta"
        "brattain" "brown" "buck" "burnell" "cannon"
        "carson" "cartwright" "carver" "cerf" "chandrasekhar"
        "chaplygin" "chatelet" "chatterjee" "chaum" "chebyshev"
        "clarke" "cohen" "colden" "cori" "cray"
        "curie" "curran" "darwin" "davinci" "dewdney"
        "dhawan" "diffie" "dijkstra" "dirac" "driscoll"
        "dubinsky" "easley" "edison" "einstein" "elbakyan"
        "elgamal" "elion" "ellis" "engelbart" "euclid"
        "euler" "faraday" "feistel" "fermat" "fermi"
        "feynman" "franklin" "gagarin" "galileo" "galois"
        "ganguly" "gates" "gauss" "germain" "goldberg"
        "goldstine" "goldwasser" "golick" "goodall" "gould"
        "greider" "grothendieck" "haibt" "hamilton" "haslett"
        "hawking" "heisenberg" "hellman" "hermann" "herschel"
        "hertz" "heyrovsky" "hodgkin" "hofstadter" "hoover"
        "hopper" "hugle" "hypatia" "ishizaka" "jackson"
        "jang" "jemison" "jennings" "jepsen" "johnson"
        "joliot" "jones" "kalam" "kapitsa" "kare"
        "keldysh" "keller" "kepler" "khayyam" "khorana"
        "kilby" "kirch" "knuth" "kowalevski" "lalande"
        "lamarr" "lamport" "leakey" "leavitt" "lederberg"
        "lehmann" "lewin" "lichterman" "liskov" "lovelace"
        "lumiere" "mahavira" "margulis" "matsumoto" "maxwell"
        "mayer" "mccarthy" "mcclintock" "mclaren" "mclean"
        "mcnulty" "meitner" "mendel" "mendeleev" "meninsky"
        "merkle" "mestorf" "mirzakhani" "montalcini" "moore"
        "morse" "moser" "murdock" "napier" "nash"
        "neumann" "newton" "nightingale" "nobel" "noether"
        "northcutt" "noyce" "panini" "pare" "pascal"
        "pasteur" "payne" "perlman" "pike" "poincare"
        "poitras" "proskuriakova" "ptolemy" "raman" "ramanujan"
        "rhodes" "ride" "ritchie" "robinson" "roentgen"
        "rosalind" "rubin" "saha" "sammet" "sanderson"
        "satoshi" "shamir" "shannon" "shaw" "shirley"
        "shockley" "shtern" "sinoussi" "snyder" "solomon"
        "spence" "stonebraker" "sutherland" "swanson" "swartz"
        "swirles" "taussig" "tesla" "tharp" "thompson"
        "torvalds" "tu" "turing" "varahamihira" "vaughan"
        "villani" "visvesvaraya" "volhard" "wescoff" "wilbur"
        "wiles" "williams" "williamson" "wilson" "wing"
        "wozniak" "wright" "wu" "yalow" "yonath"
        "zhukovsky"
    )

    # Pick a random adjective and noun
    local adjective=${adjectives[$RANDOM % ${#adjectives[@]}]}
    local noun=${nouns[$RANDOM % ${#nouns[@]}]}

    # Generate 8 random letters
    local random_letters
    random_letters=$(tr -dc 'a-z0-9' < /dev/urandom | fold -w 6 | head -n 1)

    # Concatenate the parts
    local name="${adjective}_${noun}_${random_letters}"

    # Output the result
    echo "$name"
}
