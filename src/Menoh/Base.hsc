{-# OPTIONS_GHC -Wall #-}
{-# LANGUAGE ForeignFunctionInterface #-}
module Menoh.Base where

import Data.Int
import Foreign
import Foreign.C

#include <menoh/menoh.h>
#include <menoh/version.hpp>

type MenohDType = #type menoh_dtype

type MenohErrorCode = #type menoh_error_code

#enum MenohDType,,menoh_dtype_float

#enum MenohErrorCode,, \
    menoh_error_code_success, \
    menoh_error_code_std_error, \
    menoh_error_code_unknown_error, \
    menoh_error_code_invalid_filename, \
    menoh_error_code_onnx_parse_error, \
    menoh_error_code_invalid_dtype, \
    menoh_error_code_invalid_attribute_type, \
    menoh_error_code_unsupported_operator_attribute, \
    menoh_error_code_dimension_mismatch, \
    menoh_error_code_variable_not_found, \
    menoh_error_code_index_out_of_range, \
    menoh_error_code_json_parse_error, \
    menoh_error_code_invalid_backend_name, \
    menoh_error_code_unsupported_operator, \
    menoh_error_code_failed_to_configure_operator, \
    menoh_error_code_backend_error, \
    menoh_error_code_same_named_variable_already_exist

foreign import ccall unsafe menoh_get_last_error_message
  :: IO CString

data MenohModelData
type MenohModelDataHandle = Ptr MenohModelData

foreign import ccall safe menoh_make_model_data_from_onnx
  :: CString -> Ptr MenohModelDataHandle -> IO MenohErrorCode

foreign import ccall "&menoh_delete_model_data" menoh_delete_model_data_funptr
  :: FunPtr (MenohModelDataHandle -> IO ())

data MenohVariableProfileTableBuilder
type MenohVariableProfileTableBuilderHandle = Ptr MenohVariableProfileTableBuilder

foreign import ccall unsafe menoh_make_variable_profile_table_builder
  :: Ptr MenohVariableProfileTableBuilderHandle -> IO MenohErrorCode

foreign import ccall "&menoh_delete_variable_profile_table_builder"
  menoh_delete_variable_profile_table_builder_funptr
  :: FunPtr (MenohVariableProfileTableBuilderHandle -> IO ())

foreign import ccall unsafe menoh_variable_profile_table_builder_add_input_profile_dims_2
  :: MenohVariableProfileTableBuilderHandle -> CString -> MenohDType -> Int32 -> Int32 -> IO MenohErrorCode

foreign import ccall unsafe menoh_variable_profile_table_builder_add_input_profile_dims_4
  :: MenohVariableProfileTableBuilderHandle -> CString -> MenohDType -> Int32 -> Int32 -> Int32 -> Int32 -> IO MenohErrorCode

foreign import ccall unsafe menoh_variable_profile_table_builder_add_output_profile
  :: MenohVariableProfileTableBuilderHandle -> CString -> MenohDType -> IO MenohErrorCode

data MenohVariableProfileTable
type MenohVariableProfileTableHandle = Ptr MenohVariableProfileTable

foreign import ccall safe menoh_build_variable_profile_table
  :: MenohVariableProfileTableBuilderHandle -> MenohModelDataHandle
  -> Ptr MenohVariableProfileTableHandle -> IO MenohErrorCode

foreign import ccall "&menoh_delete_variable_profile_table"
  menoh_delete_variable_profile_table_funptr
  :: FunPtr (MenohVariableProfileTableHandle -> IO ())

foreign import ccall unsafe menoh_variable_profile_table_get_dtype
 :: MenohVariableProfileTableHandle -> CString -> Ptr MenohDType -> IO MenohErrorCode

foreign import ccall unsafe menoh_variable_profile_table_get_dims_size
 :: MenohVariableProfileTableHandle -> CString -> Ptr Int32 -> IO MenohErrorCode

foreign import ccall unsafe menoh_variable_profile_table_get_dims_at
 :: MenohVariableProfileTableHandle -> CString -> Int32 -> Ptr Int32 -> IO MenohErrorCode

foreign import ccall safe menoh_model_data_optimize
  :: MenohModelDataHandle -> MenohVariableProfileTableHandle -> IO MenohErrorCode

data MenohModelBuilder
type MenohModelBuilderHandle = Ptr MenohModelBuilder

foreign import ccall unsafe menoh_make_model_builder
  :: MenohVariableProfileTableHandle -> Ptr MenohModelBuilderHandle -> IO MenohErrorCode

foreign import ccall "&menoh_delete_model_builder" menoh_delete_model_builder_funptr
  :: FunPtr (MenohModelBuilderHandle -> IO ())

foreign import ccall unsafe menoh_model_builder_attach_external_buffer
  :: MenohModelBuilderHandle -> CString -> Ptr a -> IO MenohErrorCode

data MenohModel
type MenohModelHandle = Ptr MenohModel

foreign import ccall safe menoh_build_model
  :: MenohModelBuilderHandle -> MenohModelDataHandle -> CString -> CString
  -> Ptr MenohModelHandle -> IO MenohErrorCode

foreign import ccall "&menoh_delete_model" menoh_delete_model_funptr
  :: FunPtr (MenohModelHandle -> IO ())

foreign import ccall unsafe menoh_model_get_variable_buffer_handle
  :: MenohModelHandle -> CString -> Ptr (Ptr a) -> IO MenohErrorCode

foreign import ccall unsafe menoh_model_get_variable_dtype
  :: MenohModelHandle -> CString -> Ptr MenohDType -> IO MenohErrorCode

foreign import ccall unsafe menoh_model_get_variable_dims_size
  :: MenohModelHandle -> CString -> Ptr Int32 -> IO MenohErrorCode

foreign import ccall unsafe menoh_model_get_variable_dims_at
  :: MenohModelHandle -> CString -> Int32 -> Ptr Int32 -> IO MenohErrorCode

foreign import ccall safe menoh_model_run
  :: MenohModelHandle -> IO MenohErrorCode

menoh_major_version :: Int
menoh_major_version = #const MENOH_MAJOR_VERSION

menoh_minor_version :: Int
menoh_minor_version = #const MENOH_MINOR_VERSION

menoh_patch_version :: Int
menoh_patch_version = #const MENOH_PATCH_VERSION

menoh_version_string :: String
menoh_version_string = #const_str MENOH_VERSION_STRING
