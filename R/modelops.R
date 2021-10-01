#' Create a modelops object for deployment of a trained caret model
#'
#' A [modelops::modelops()] object collects the information needed to store, version,
#' and deploy a trained model.
#'
#' @param model A trained model created with [caret::train()].
#' @param data A data frame of _predictor_ columns in the same format that was
#' given to the modeling function.
#' @inheritParams modelops::modelops
#' @export
modelops.train <- function(model,
                           model_name,
                           board,
                           data,
                           ...,
                           desc = NULL,
                           metadata = list(),
                           ptype = TRUE,
                           versioned = NULL) {


    model <- butcher::butcher(model)
    ptype <- modelops::modelops_create_ptype(model, ptype, data)
    required_pkgs <- c("caret", model$modelInfo$library)

    if (rlang::is_null(desc)) {
        desc <- glue("A {tolower(model$modelInfo$label)} {tolower(model$modelType)} model")
    }

    modelops::new_modelops(
        model = model,
        model_name = model_name,
        board = board,
        desc = as.character(desc),
        metadata = modelops::modelops_meta(metadata,
                                           required_pkgs = required_pkgs),
        ptype = ptype,
        versioned = versioned
    )
}


#' @export
modelops_slice_zero.train <- function(model, data, ...) {
    data[0,,drop = FALSE]
}

