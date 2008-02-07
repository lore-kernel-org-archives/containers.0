From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][DOCUMENTATION] Minimal controller code for a quick start
Date: Thu, 7 Feb 2008 14:50:21 -0600
Message-ID: <20080207205021.GB16628@sergelap.ibm.com>
References: <47AB25AD.30400@openvz.org> <1202416137.6274.42.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1202416137.6274.42.camel@lappy>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Peter Zijlstra (a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org):
> 
> On Thu, 2008-02-07 at 18:37 +0300, Pavel Emelyanov wrote:
> > The Documentation/cgroups.txt file contains the info on how
> > to write some controller for cgroups subsystem, but even with
> > this, one need to write quite a lot of code before developing
> > the core (or copy-n-paste it from some other place).
> > 
> > I propose to put this minimal controller into Documentation
> > directory to let people copy-n-paste a) from a known place and 
> > b) a small piece of code.
> > 
> > Besides, many people learn better reading an example rather
> > than/along with a document.
> 
> 
> While on the subject, could someone document struct cgroup_subsys. In
> particular, I've wondered why we have: cgroup_subsys::can_attach() and

The point of can_attach() is to decide whether an attach should be
permitted.  kernel/ns_cgroup.c defines it.

> not use a return value in cgroup_subsys::attach()?

IIUC, by the point ->attach() is called, the task has already been placed
in the new cgroup, and we're just asking each subsystem to update any
relevant accounting.

-serge
