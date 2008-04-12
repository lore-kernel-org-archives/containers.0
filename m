From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 0/4] Helper patches for PTY namespaces
Date: Sat, 12 Apr 2008 12:06:55 -0700
Message-ID: <1208027215.28187.17.camel@x61.ebiederm.org>
References: <20080412172933.GA19295@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757896AbYDLTH1@vger.kernel.org>
In-Reply-To: <20080412172933.GA19295@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, matthltc@us.ibm.com, hpa@zytor.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Sat, 2008-04-12 at 10:29 -0700, sukadev@us.ibm.com wrote:
> Some simple helper patches to enable implementation of multiple PTY
> (or device) namespaces.
> 
> 	[PATCH 1/4]: Propagate error code from devpts_pty_new
> 	[PATCH 2/4]: Factor out PTY index allocation
> 	[PATCH 3/4]: Move devpts globals into init_pts_ns
> 	[PATCH 3/4]: Enable multiple mounts of /dev/pts
> 
> This patchset is based on earlier versions developed by Serge Hallyn
> and Matt Helsley.

Suka Stop.

The first two patches appear to just be cleanups and as such should be
able to stand on their own.  Mentioning that you found these
opportunities while working on your pts namespace is fine.  Justifying
the cleanups this way is not.

When you mentioned you intended to just resend the cleanups this is not
at all what I thought you were about.  So please just get the first two
patches in a form that stands by themselves.

The pts namespace as designed is not acceptable.

The problem you are trying to solve with the pts namespace is real.

So what we need is a device namespace and possibly and incremental path
to get there.  A device namespace would abstract the device number to
device mapping for all devices.  A safe incremental path would disable
all device number to device mappings for process in that namespace.  So
all functionality would be gone, then it would enable certain mappings
and certain pieces of the functionality if the code in the kernel is not
clean enough that we can do it all in one go.

We need to see that path.  Only then can we take patches that add
namespace specific goo.  The pattern I am proposing has worked quite
well for the network namespace.  Meanwhile the uid namespace which
follows the pattern you seem to be following now seems does not look to
be completed any time soon.

So send your clean up patches and then let's architect this thing so we
are really talking about a namespace.  Then we can update devpts to
capture the device namespace on mount and do it's work in a namespace
specific manner.

Eric
