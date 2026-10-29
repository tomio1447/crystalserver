////////////////////////////////////////////////////////////////////////
// Crystal Server - an opensource roleplaying game
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////

#include "crystalserver.hpp"
#include "lib/di/container.hpp"

#ifdef _WIN32
	#include <windows.h>
	#include <cstdio>

static LONG WINAPI wariziCrashFilter(EXCEPTION_POINTERS* info) {
	if (const auto f = fopen("crash_report.log", "a")) {
		const auto base = reinterpret_cast<const char*>(GetModuleHandleA(nullptr));
		fprintf(
			f, "CRASH: code=0x%08lx addr=%p rip_rva=0x%llx time=%llu\n",
			info->ExceptionRecord->ExceptionCode,
			info->ExceptionRecord->ExceptionAddress,
			(unsigned long long)((const char*)info->ExceptionRecord->ExceptionAddress - base),
			(unsigned long long)time(nullptr)
		);
		void* frames[32] = {};
		const USHORT n = RtlCaptureStackBackTrace(1, 32, frames, nullptr);
		for (USHORT i = 0; i < n; ++i) {
			fprintf(f, "  frame[%u]=0x%llx\n", i, (unsigned long long)((const char*)frames[i] - base));
		}
		fclose(f);
	}
	return EXCEPTION_CONTINUE_SEARCH;
}
#endif

int main() {
#ifdef _WIN32
	SetUnhandledExceptionFilter(wariziCrashFilter);
#endif
	return inject<CrystalServer>().run();
}
