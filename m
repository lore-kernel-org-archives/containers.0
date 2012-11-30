From: Matt Helsley <matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Mapping between host & container PIDs ?
Date: Thu, 29 Nov 2012 16:43:06 -0800
Message-ID: <20121130004306.GA29657@us.ibm.com>
References: <20121127101555.GE24370@redhat.com>
	<20121127133609.GC3727@sergelap> <87vccrm9xw.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87vccrm9xw.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 27, 2012 at 07:50:35AM -0600, Eric W. Biederman wrote:
> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> 
> > Quoting Daniel P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> >> I'm trying to find out if there is a way to map between host and container
> >> PIDs, at minimum in the host -> container direction. My use case is to be
> >> able to kill processes associated with a container, based on the host PID,
> >> in a race free manner.
> >> 
> >> Given a host PID, I can read the 'tasks' file for the container's cgroup
> >> to verify that the PID is associated with the container in question. Then
> >> I can kill the PID with a signal. There is a small race condition in there,
> >> where the PID could die & a new process could be born using the original
> >> PID. Now this might not be very likely but I was thinking that if it is
> >> possible to map from a host PID to a container PID, you can do it more
> >> safely. eg Lookup the container PID associted with the host PID, then
> >> setns() into the container and kill the container PID. Now although there
> >> is still a race condition, you are guaranteed that if the race hits you'll
> >> only kill a process within the same container, not the host at large,
> >> which is good when the user invoking the API is unprivileged.
> >
> > I'm afraid I don't know of any way to do that.  At some point a new
> > /proc/self/pids or somesuch file was suggested to get that info.
> 
> I do wonder how the checkpoint/restart folks are getting that
> information.

Perhaps via the parasite thread? I guess they just inject code that does
getpid(), and, because we know which process they ptrace'd on the host
side, they know the mapping in both pid namespaces.

Cheers,
	-Matt Helsley
