From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] userns: Support fuse interacting with multiple user
	namespaces
Date: Mon, 12 Nov 2012 18:37:33 -0800
Message-ID: <878va6i5xu.fsf@xmission.com>
References: <87objjcfp4.fsf@xmission.com>
	<87625brr76.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87625brr76.fsf-d8RdFUjzFsbxNFs70CDYszOMxtEWgIxa@public.gmane.org> (Miklos Szeredi's message
	of "Mon, 12 Nov 2012 12:33:33 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org> writes:

> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
>
>> Use kuid_t and kgid_t in struct fuse_conn and struct fuse_mount_data.
>>
>> The connection between between a fuse filesystem and a fuse daemon is
>> established when a fuse filesystem is mounted and provided with a file
>> descriptor the fuse daemon created by opening /dev/fuse.
>>
>> For now restrict the communication of uids and gids between the fuse
>> filesystem and the fuse daemon to the initial user namespace.
>
> Why?
>
> I think far more logical would be to limit a single instance of the
> filesystem and the daemon to an arbitrary but *single* namespace.
> I.e. one fuse_conn <-> one user namespace.
>
> Is there a reason to treat the initial namespace specially?

Stepwise making this work.

The initial user namespace is special in that is the only user namespace
you can currently mount a filesystem in.

My goal with the posted patch is to support users on the other side of
the vfs that are in multiple user namespaces.  Which basically means
accepting kuid_t and kgid_t values and converting them to uid_t and
gid_t values where needed.

As for creating a version of fuse that can be mounted in different user
namespaces and can communicate with the fuse daemon in the user
namespace the filesystem was mounted in, I have a preliminary patch for
that.  My goal with that patch is to support unprivileged mounts of fuse
without the help of a suid root mount program.  But that patch is more
involved and not quite ready yet.

I want to get to the point that I can enable fuse and user namespaces at
the same time (what this patch allows) and then put in the effort to
fully take advantage of user namespaces.

Eric
