From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] userns: allow privileged user to operate locked mount
Date: Thu, 14 Nov 2013 17:38:48 -0800
Message-ID: <871u2i30lz.fsf@xmission.com>
References: <1384327663-12032-1-git-send-email-gaofeng@cn.fujitsu.com>
	<874n7e4k78.fsf@xmission.com> <52856F0D.8090206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52856F0D.8090206-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Fri, 15
	Nov 2013 08:47:09 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 11/15/2013 07:50 AM, Eric W. Biederman wrote:
>> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>> 
>>> Privileged user should have rights to mount/umount/move
>>> these even locked mount.
>> 
>> Hmm. This is pretty much a can't happen case, as the only exist in mount
>> namespaces where the global root isn't the root.  How are you getting
>> into this situation?  Using setns() ?
>> 
>
> Before, priviged user can use setns to set his mount namespace to the
> container's mount namespace, and change container's mount directly.
> this patch just gives back host the control of container.

Having thought about this patch a little more I really don't like it.

There are other ways for a privileged user to get around the limitations
when the mount namespace is being created or the mounts are being
propagated.

This approach would require more then a signgle bit of accounting to
work in the nested user namespace case.

The lock says one or several mounts are mounted as a unit and need to
stay that way.

If there are real advantages to splitting things up I might be persuaded
to change my mind.  But right now it looks like you are introducing
extra complexity for a very corner edge case that we don't want to
encourage people to use.

Eric
