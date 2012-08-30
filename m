From: "Muralidhar, Rajeev D" <rajeev.d.muralidhar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [CRIU] Re: Error compiling CRtools-0.1..
Date: Thu, 30 Aug 2012 13:16:27 +0000
Message-ID: <604C0E70D2B64644B0BCE6939D9F7D0327E623@BGSMSX102.gar.corp.intel.com>
References: <604C0E70D2B64644B0BCE6939D9F7D0327A1C6@BGSMSX102.gar.corp.intel.com>
	<604C0E70D2B64644B0BCE6939D9F7D0327E011@BGSMSX102.gar.corp.intel.com>
	<20120830125557.GB8474@amd1> <20120830131058.GK21422@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120830131058.GK21422@moon>
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
To: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Cyril

Yes, that is the branch I am running - 3.6-rc1. And I have all the config options turned on in the kernel as documented in the crui.org website. 

The errors I am seeing seem to be coming from netlink. What are the dependencies on netlink packages? Error seems to be suggesting that it cant stat any of the netlink sockets. 

Thanks
Rajeev


-----Original Message-----
From: Cyrill Gorcunov [mailto:gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] On Behalf Of Cyrill Gorcunov
Sent: Thursday, August 30, 2012 6:41 PM
To: Serge Hallyn
Cc: Muralidhar, Rajeev D; criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Subject: Re: [CRIU] Re: Error compiling CRtools-0.1..

On Thu, Aug 30, 2012 at 07:55:58AM -0500, Serge Hallyn wrote:
> Please cc: criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org (I've cc:d them here) on crtools questions.
> 

Thanks, Serge!

We support x86-64 only for a while. Please make sure you're running branch "crtools-3.6-rc1" of the kernel, we've moved our kernel to kernel.org, so fetch it here

	git://git.kernel.org/pub/scm/linux/kernel/git/gorcunov/linux-cr.git

Also make sure you've all needed CONFIG_ options turned on, see Kernel configuration in http://criu.org/CR_tools. Does it help?
