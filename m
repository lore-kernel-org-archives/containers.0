From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCHv3] locks: Filter /proc/locks output on proc pid ns
Date: Wed, 03 Aug 2016 23:18:06 -0500
Message-ID: <87eg659ngh.fsf@x220.int.ebiederm.org>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470236078-2389-1-git-send-email-kernel@kyup.com>
	<87k2fxom8a.fsf@x220.int.ebiederm.org>
	<1470243015.13804.7.camel@poochiereds.net>
	<87twf1ftk9.fsf@x220.int.ebiederm.org>
	<a0a58f75-0e40-c14f-d8e3-8f094e9fc62c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a0a58f75-0e40-c14f-d8e3-8f094e9fc62c-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Nikolay
	Borisov's message of "Thu, 4 Aug 2016 00:26:17 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On  4.08.2016 00:09, Eric W. Biederman wrote:
>> Dumb question does anyone know the difference between fl_nspid and
>> fl_pid off the top of your heads?  I am looking at the code and I am
>> confused why we have to both.  I am afraid that there was some
>> sloppiness when the pid namespace was implemented and this was the
>> result.  I remember that file locks were a rough spot during the
>> conversion but I don't recall the details off the top of my head.
>
> I think the fl_nspid is the actual pid namespace where the lock was
> created, where as pid can be just a unique value required by NFS. I
> gathered that information while reading the changelogs and the mailing
> list discussion here:
> https://lists.linuxfoundation.org/pipermail/containers/2007-December/009044.html

Thanks for the old thread.

Researching myself I see that for posix locks we have struct flock
that has a field l_pid that must be the pid of the process holding
the lock.

It looks like the explanation given in the old thread was inadequate,
and the code in the kernel is definitely incorrect with respect to pid
namespaces.  If the process holding the lock is in a different pid
namespace than the process waiting for the lock l_pid will be set
incorrectly.

Looking at the code it appears from the perspective of struct file_lock
the only difference between a remote lock and a local lock is that
fl_owner is set to point at a different structure.

Looking at the nfs case if I am reading my sources correctly the struct
nlm field named svid is the process id on the remote system, and other
nlm fields distinguish the host.

Is the desired behavior for nfs that for a remote lock we set l_pid
to the remote process id, and don't report a hint about which machine
the process id is on?

It does seem to make sense to have both fl_pid as a value usable
remotely and otherwise and fl_nspid (arguably it should be fl_local_pid)
as a value usable on the local machine.

I think the code that sets fl_nspid today is anything but obviously
correct and probably needs to be rewritten.

Eric
