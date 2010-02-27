From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/4][user-cr]: First try at integrating LXC
	and	USER-CR
Date: Fri, 26 Feb 2010 21:14:31 -0500
Message-ID: <4B888007.9050501@cs.columbia.edu>
References: <20100224083452.GB18758@us.ibm.com>
	<4B88429B.4000701@cs.columbia.edu>
	<20100227001002.GA22965@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100227001002.GA22965-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
>> Suka,
>>
>> This is good stuff: convert restart to a library and intergate
>> with LXC is excellent target.
>>
>> We need to give a thought to the API design and the sort of
>> functionality that the library will offer. I'd prefer to get
>> a better view of the whole plan before committing to any
>> incremental step.
>>
>> For example:
>>
>> * what prefix will the library calls have ?  e.g. cr_checkpoint(),
>> cr_restart() etc.  Could also be checkpoint_... or ckpt_... In
>> any case, must be consistent and unique, and also agree with the
>> library name: libcheckpoint.a and usercr.h doesn't make sense to
>> me.
> 
> Agree. I have been worried about publishing an interface and getting
> stuck with a bad interface. But I have also been trying to prototype
> interface with LIBLXC available so did not yet spend lot of time
> on the interface.
> 
> I have been meaning to add a disclaimer to usercr.h that the structures
> will change without regard to backward compatibility
> 
> libcheckpoint.a looked like a reasonable name but for the header,
> we already have a checkpoint.h from the kernel :-) Open to new/better
> names/prefixes for the library calls.

we have sys/checkpoint.h, so it makes sense to have checkpoint.h :)

> 
> Anyway, these names are just for the prototype and to start a discussion,
> My guess is that we are not ready to publish a formal interface at
> this point, but we can start moving towards that.
> 
> My current pass has been to eliminate all global references in
> app_restart() and app_checkpoint() (like perror(), stderr, stdout etc).
> while preserving the current behavior. Once we have an interface
> that LIBLXC can use, maybe we could focus more on stabilizing
> the interface ? It seemed to hard to do that with all the
> globals in the code.
> 
>> * what arguments are really necessary in struct restart_args ? for
>> example, a ->logfd is necessary, but ->logfile (pathname) is not
>> (the caller should already open the file)
> 
> I have several small patches to clean this up. Was hoping to post
> later today. They remove ->logfile, ->input, ->output fromt he
> structures and just leave the relevant fds.

What I suggest is to avoid unnecessary work and fixes, it's worth
our while to discuss what could be the api and functionality even
before getting into the implementation details.etc.

Also, two important points that I had meant to mention are:

* versioning: we should provision for api extensions, e.g. in the
struct restart_args, or at the very least a way to figure out the
version.

* hooks / plugins: allow the user to request hooks or plugins,
for example after checkpoint completes but before applications
are thawed, or in restart after the tree is created but before
tasks call sys_restart(). another example - handling the mount-
namespace (and remounting the pty) could be a plugin.

Oren.

> 
>> * the library should provide an api to initialize the default args
>> (e.g. the logfd should be -1 by default), e.g. cr_init_restart_args()
>>
>> * similarly, only constants and macros relevant to a caller
>> should be exposed, not internal data structures or macros.
>>
>> * verbosity, debugging, warn and fail: currently that can be
>> configurable to some extent; but we should never impose on the
>> caller a perror() - instead the caller should pass FILE * for
>> stdout and stderr (if NULL - the library will keep silent).
> 
> Yes, my current patchset uses a restart_args->ulogfd for the
> user-space error messages. The restart-main.c sets this field
> to fileno(stderr).
> 
>> * probably makes sense to add interface to freeze a process tree
>> identified by its root pid, and thaw a process tree (or a cgroup).
> 
> True. For the near-term, LIBLXC has a way to freeze/thaw the containers
> 
>> * does the mnt-ns manipulation belong to cr_restart() ?  perhaps
>> make it a separate api in the library ?
> 
> Good point. We need to think about that.
> 
>> * we need to change the way restart detects errors and cleans up
>> from relying on signals to, e.g. on pipes. I've been wanting to
>> do this for the longest time, and it will eliminate most (if not
>> all) of the global variables.
> 
> Ok.
> 
