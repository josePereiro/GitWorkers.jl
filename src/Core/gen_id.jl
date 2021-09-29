const _ID_ALPHABET_ = join(['a':'z'; 'A':'Z'; '0':'9'])
const _ID_LENGTH_ = 8

_gen_id(tlen::Int = _ID_LENGTH_; abc = _ID_ALPHABET_) = join(rand(abc, tlen))
_gen_id(tag::AbstractString, tlen::Int = _ID_LENGTH_; abc = _ID_ALPHABET_) = string(tag, _gen_id(tlen; abc))