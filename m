From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC PATCH] locks: Show only file_locks created in the same
	pidns as current process
Date: Tue, 2 Aug 2016 15:44:37 -0400
Message-ID: <20160802194437.GD15324@fieldses.org>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<87r3a7qhy0.fsf@x220.int.ebiederm.org>
	<20160802174003.GD11767@fieldses.org>
	<87invjq97h.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87invjq97h.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 02, 2016 at 02:09:22PM -0500, Eric W. Biederman wrote:
> "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:
> 
> > On Tue, Aug 02, 2016 at 11:00:39AM -0500, Eric W. Biederman wrote:
> >> Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
> >> 
> >> > Currently when /proc/locks is read it will show all the file locks
> >> > which are currently created on the machine. On containers, hosted
> >> > on busy servers this means that doing lsof can be very slow. I
> >> > observed up to 5 seconds stalls reading 50k locks, while the container
> >> > itself had only a small number of relevant entries. Fix it by
> >> > filtering the locks listed by the pidns of the current process
> >> > and the process which created the lock.
> >> 
> >> The locks always confuse me so I am not 100% connecting locks
> >> to a pid namespace is appropriate.
> >> 
> >> That said if you are going to filter by pid namespace please use the pid
> >> namespace of proc, not the pid namespace of the process reading the
> >> file.
> >
> > Oh, that makes sense, thanks.
> >
> > What does /proc/mounts use, out of curiosity?  The mount namespace that
> > /proc was originally mounted in?
> 
> /proc/mounts -> /proc/self/mounts

D'oh, I knew that.

> /proc/[pid]/mounts lists mounts from the mount namespace of the
> appropriate process.
> 
> That is another way to go but it is a tread carefully thing as changing
> things that way it is easy to surprise apparmor or selinux rules and be
> surprised you broke someones userspace in a way that prevents booting.
> Although I suspect /proc/locks isn't too bad.

OK, thanks.

/proc/[pid]/locks might be confusing.  I'd expect it to be "all the
locks owned by this task", rather than "all the locks owned by pid's in
the same pid namespace", or whatever criterion we choose.

Uh, I'm still trying to think of the Obviously Right solution here, and
it's not coming.

--b.
