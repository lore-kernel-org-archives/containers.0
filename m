From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Sat, 20 Nov 2010 13:05:15 -0500 (EST)
Message-ID: <4CE69B9B.7020302@cs.columbia.edu>
References: <20101104164401.GC10656@sundance.ccs.neu.edu> <4CD3CE29.2010105@kernel.org>
 <20101106053204.GB12449@count0.beaverton.ibm.com> <20101106204008.GA31077@sundance.ccs.neu.edu>
 <4CD5D99A.8000402@cs.columbia.edu> <20101107184927.GF31077@sundance.ccs.neu.edu>
 <4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
 <20101117153902.GA1155@hallyn.com> <4CE3F8D1.10003@kernel.org>
 <20101119041045.GC24031@hallyn.com> <4CE683E1.6010500@kernel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CE683E1.6010500@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Serge Hallyn <serge.hallyn@canonical.com>, Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, linux-kernel@vger.kernel.org, xemul@sw.ru, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hi,

Based on discussion with Gene, I'd like to clarify key points and
difference between kernel and userspace approaches (specifically
linux-cr and dmtcp): three parts to break the long post...

part I: perpsectice about the types of scopes of c/r in discussion
part II: linux-cr design adn objectives
part III: comparison kernel/userspace approaches

[now relax, grab (another) cup of coffee and read on...]

PART I:  ==PERSPECTIVE==

A rough classification of c/r categories:

* container-c/r: important use-case, e.g. c/r and migration of an
  application containers like VPS (virtual private server), VDI
  (desktop) or  other self-contained application (e.g. Oracle server).
  Here _all_ the relevant processes are included in the checkpoint.

* standalone-c/r: another use-case is standalone-c/r where a set of
  processes is checkpointed, but not the entire environment, and then
  those processes are restarted in a different "eco-system".

* distributed-c/r: meaning several sets of processes, each running
  on a different host. (Each set may be a separate container there).

In container-c/r, the main challenge is to be _reliable_ in the sense
that a restart from a successful checkpoint should always succeed.

In standalone-c/r, the main challenge is that an application resumes
execution after a restart in a possible _different_ eco-system. Some
application don't care (e.g 'bc'). Other applications do care, and to
different degrees; for these we need "glue" to pacify the application.

There are generally three types of "glue":

(1) Modify the application or selected libraries to be c/r-aware, and
  notify it when restart completes. (e.g. CoCheck MPI library).
(2) Add a userspace helper that will run post-restart to do necessary
  trickery (eg. send a SIGWINCH to 'screen'; mount proper filesystem
  at the new host after migration; reconnect a socket to a peer).
(3) Use interposition on selected library calls and add wrapper code
  that will glue in what's missing (e.g. dbus or nscd calls to
  reconnect an application to those services).

IMPORTANT: the glueing method is _orthogonal_ to how the c/r is done !
We are strictly discussion the core c/r functionality.

(next part: linux-cr philosophy...)

Thanks,

Oren.
