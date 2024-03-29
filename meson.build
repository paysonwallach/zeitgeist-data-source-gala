project(
  'zeitgeist-data-source-gala',
  'vala',
  'c',
  license: ['GPL3'],
  meson_version: '>=0.56.0',
  version: '0.1.0'
)

vala = meson.get_compiler('vala')

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
plugins_dir = join_paths(get_option('prefix'), get_option('libdir'), 'gala', 'plugins')
vapi_dir = join_paths(meson.current_source_dir(), 'vapi')

glib_version_required = '2.44.0'
gtk_version_required = '3.10.0'

gala_dep = dependency('gala')
gee_dep = dependency('gee-0.8')
glib_dep = dependency('glib-2.0', version: '>= @0@'.format(glib_version_required))
gobject_dep = dependency('gobject-2.0', version: '>= @0@'.format(glib_version_required))
gio_unix_dep = dependency('gio-unix-2.0')
zeitgeist_dep = dependency('zeitgeist-2.0')

mutter_dep = []
libmutter_dep = []

vala_flags = []
c_flags = [
  '-DCLUTTER_ENABLE_COMPOSITOR_API',
  '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
  '-DCOGL_ENABLE_EXPERIMENTAL_API',
  '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API'
]

mutter328_dep = dependency('libmutter-2', version: ['>= 3.27', '< 3.29'], required: false)
if mutter328_dep.found()
  libmutter_dep = dependency('libmutter-2', version: '>= 3.27.92')
  mutter_dep = [
    dependency('mutter-cogl-2'), dependency('mutter-cogl-pango-2'),
    dependency('mutter-cogl-path-2'), dependency('mutter-clutter-2')
  ]
endif

mutter330_dep = dependency('libmutter-3', version: ['>= 3.29.4', '< 3.31'], required: false)
if mutter330_dep.found()
  libmutter_dep = dependency('libmutter-3', version: '>= 3.29.4')
  mutter_dep = [
    dependency('mutter-cogl-3'), dependency('mutter-cogl-pango-3'),
    dependency('mutter-cogl-path-3'), dependency('mutter-clutter-3')
  ]
  vala_flags = ['--define', 'HAS_MUTTER330']
endif

mutter332_dep = dependency('libmutter-4', version: ['>= 3.31.2', '< 3.34'], required: false)
if mutter332_dep.found()
  libmutter_dep = dependency('libmutter-4', version: '>= 3.31.2')
  mutter_dep = [
    dependency('mutter-cogl-4'), dependency('mutter-cogl-pango-4'),
    dependency('mutter-cogl-path-4'), dependency('mutter-clutter-4')
  ]
  vala_flags = ['--define', 'HAS_MUTTER330', '--define', 'HAS_MUTTER332']
endif

mutter334_dep = dependency('libmutter-5', version: ['>= 3.34', '< 3.35.1'], required: false)
if mutter334_dep.found()
  libmutter_dep = dependency('libmutter-5', version: '>= 3.34')
  mutter_dep = [
    dependency('mutter-cogl-5'), dependency('mutter-cogl-pango-5'),
    dependency('mutter-cogl-path-5'), dependency('mutter-clutter-5')
  ]
  vala_flags = ['--define', 'HAS_MUTTER330', '--define', 'HAS_MUTTER332', '--define', 'HAS_MUTTER334']
endif

mutter336_dep = dependency('libmutter-6', version: ['>= 3.35.1', '< 3.37'], required: false)
if mutter336_dep.found()
  libmutter_dep = dependency('libmutter-6', version: '>= 3.35.1')
  mutter_dep = [
    dependency('mutter-cogl-6'), dependency('mutter-cogl-pango-6'),
    dependency('mutter-cogl-path-6'), dependency('mutter-clutter-6')
  ]
  vala_flags = ['--define', 'HAS_MUTTER330', '--define', 'HAS_MUTTER332', '--define', 'HAS_MUTTER334', '--define', 'HAS_MUTTER336']
endif

mutter338_dep = dependency('libmutter-7', version: ['>= 3.37', '< 3.39'], required: false)
if mutter338_dep.found()
  libmutter_dep = dependency('libmutter-7', version: '>= 3.37')
  mutter_dep = [
    dependency('mutter-cogl-7'), dependency('mutter-cogl-pango-7'),
    dependency('mutter-clutter-7')
  ]
  vala_flags = ['--define', 'HAS_MUTTER330', '--define', 'HAS_MUTTER332', '--define', 'HAS_MUTTER334', '--define', 'HAS_MUTTER336', '--define', 'HAS_MUTTER338']
endif

if mutter_dep.length() == 0
  error ('No supported mutter library found!')
endif

mutter_typelib_dir = libmutter_dep.get_pkgconfig_variable('typelibdir')

conf = configuration_data()
conf.set_quoted('APPLICATION_ID', meson.project_name())
conf.set_quoted('APPLICATION_NAME', run_command('sh', '-c', 'cat @0@ | jq -r ".name"'.format(join_paths(meson.project_source_root(), 'package.json'))).stdout().strip())
conf.set_quoted('APPLICATION_DESCRIPTION', run_command('sh', '-c', 'cat @0@ | jq -r ".description"'.format(join_paths(meson.project_source_root(), 'package.json'))).stdout().strip())

config_h = configure_file(
output: 'config.h',
  configuration: conf
)

config_dep = declare_dependency(
  dependencies: vala.find_library('config', dirs: vapi_dir),
  sources: config_h
)

config_inc_dir = include_directories('.')

add_project_arguments(
  ['-DG_LOG_DOMAIN="@0@"'.format(meson.project_name())],
  language:'c'
)

add_project_arguments(
  ['--vapidir', vapi_dir],
  language: 'vala',
)

subdir('data')
subdir('lib')
