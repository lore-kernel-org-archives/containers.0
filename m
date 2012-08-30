From: "Muralidhar, Rajeev D" <rajeev.d.muralidhar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [CRIU] Re: Error compiling CRtools-0.1..
Date: Thu, 30 Aug 2012 14:27:17 +0000
Message-ID: <604C0E70D2B64644B0BCE6939D9F7D0327E721@BGSMSX102.gar.corp.intel.com>
References: <604C0E70D2B64644B0BCE6939D9F7D0327A1C6@BGSMSX102.gar.corp.intel.com>
	<604C0E70D2B64644B0BCE6939D9F7D0327E011@BGSMSX102.gar.corp.intel.com>
	<20120830125557.GB8474@amd1> <20120830131058.GK21422@moon>
	<604C0E70D2B64644B0BCE6939D9F7D0327E623@BGSMSX102.gar.corp.intel.com>
	<20120830133033.GL21422@moon>
	<604C0E70D2B64644B0BCE6939D9F7D0327E674@BGSMSX102.gar.corp.intel.com>
	<20120830134513.GM21422@moon>
	<604C0E70D2B64644B0BCE6939D9F7D0327E6C0@BGSMSX102.gar.corp.intel.com>
	<20120830140431.GN21422@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120830140431.GN21422@moon>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Cyril,

Here is output of uname -a

rdmurali@tapovan:~/Linux-CR/crtools-0.1$ uname -a
Linux tapovan 3.6.0-rc1 #2 SMP Thu Aug 30 08:38:17 IST 2012 x86_64 x86_64 x86_64 GNU/Linux

I got the kernel repo from: http://git.kernel.org/?p=linux/kernel/git/gorcunov/linux-cr.git;a=summary 

But I guess I didn't take crtools-3.6-rc1. OK let me get that branch and try. 

Will keep you posted. 

Thanks!
Rajeev



-----Original Message-----
From: Cyrill Gorcunov [mailto:gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] On Behalf Of Cyrill Gorcunov
Sent: Thursday, August 30, 2012 7:35 PM
To: Muralidhar, Rajeev D
Cc: Serge Hallyn; criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; Andrey Vagin
Subject: Re: [CRIU] Re: Error compiling CRtools-0.1..

On Thu, Aug 30, 2012 at 01:59:16PM +0000, Muralidhar, Rajeev D wrote:
> Hi Cyril
> 
> OK I will wait for your advice. 
> 
> If I try exactly 0.1 version, this is the error I get:
> 
> rdmurali@tapovan:~/Linux-CR/crtools-0.1$ sudo ./crtools check Error 
> (cr-check.c:174): Counter mismatch (or not met) 0 want 13 Error 
> (cr-check.c:224): TFD mismatch (or not met) 0 want 4 Error 
> (cr-check.c:263): WD mismatch (or not met) -1 want 1

This rather a symptom for wrong kernel version. It's important to run "crtools-3.6-rc1" kernel, not vanilla v3.6-rc1.

	Cyrill
