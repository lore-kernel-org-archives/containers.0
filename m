From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: What can OpenVZ do?
Date: Fri, 13 Feb 2009 11:53:02 +0100
Message-ID: <20090213105302.GC4608__24954.6085986823$1234522534$gmane$org@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090212141014.2cd3d54d.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


* Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> Now, we've gone in blind before - most notably on the
> containers/cgroups/namespaces stuff.  That hail mary pass worked out
> acceptably, I think.  Maybe we got lucky.  I thought that
> net-namespaces in particular would never get there, but it did.
> 
> That was a very large and quite long-term-important user-visible
> feature.
> 
> checkpoint/restart/migration is also a long-term-...-feature.  But if
> at all possible I do think that we should go into it with our eyes a
> little less shut.

IMO, s/.../important/

More important than containers in fact. Being able to detach all
software state from the hw state and being able to reattach it:

   1) at a later point in time,                   or
   2) in a different piece of hardware,           or
   3) [future] in a different kernel

... is powerful stuff on a very conceptual level IMO.

The only reason we dont have it in every OS is not because it's not
desired and not wanted, but because it's very, very hard to do it on
a wide scale. But people would love it even if it adds (some) overhead.

This kind of featureset is actually the main motivator for virtualization.

If the native kernel was able to do checkpointing we'd have not only
near-zero-cost virtualization done at the right abstraction level
(when combined with containers/control-groups), but we'd also have
a few future feature items like:

  1) Kernel upgrades done intelligently: transparent reboot into an
     upgraded kernel.

  2) Downgrade-on-regressions done sanely: transparent downgrade+reboot
     to a known-working kernel. (as long as the regression is app
     misbehavior or a performance problem - not a kernel crash. Most
     regressions on kernel upgrades are not actual crashes or data
     corruption but functional and performance regressions - i.e. it's
     safely checkpointable and downgradeable.)

  3) Hibernation done intelligently: checkpoint everything, turn off
     system. Turn on system, restore everything from the checkpoint.

  4) Backups done intelligently: full "backups" of long-running
     computational jobs, maybe even of complex things like databases
     or desktop sessions.

  5) Remote debugging done intelligently: got a crashed session?
     Checkpoint the whole app in its anomalous state and upload the
     image (as long as you can trust the developer with that image
     and with the filesystem state that goes with it).

I dont see many long-term dragons here. The kernel is obviously always
able to do near-zero-overhead checkpointing: it knows about all its
own data structures, can enumerate them and knows how they map to
user-space objects.

The rest is performance considerations: do we want to embedd
checkpointing helpers in certain runtime codepaths, to make
checkpointing faster? But if that is undesirable (serialization,
etc.), we can always fall back to the dumbest, zero-overhead methods.

There is _one_ interim runtime cost: the "can we checkpoint or not"
decision that the kernel has to make while the feature is not complete.

That, if this feature takes off, is just a short-term worry - as
basically everything will be checkpointable in the long run.

In any case, by designing checkpointing to reuse the existing LSM
callbacks, we'd hit multiple birds with the same stone. (One of
which is the constant complaints about the runtime costs of the LSM
callbacks - with checkpointing we get an independent, non-security
user of the facility which is a nice touch.)

So all things considered it does not look like a bad deal to me - but
i might be missing something nasty.

	Ingo
