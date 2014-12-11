From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Limiting access to abstract unix domain sockets
Date: Thu, 11 Dec 2014 13:18:30 -0600
Message-ID: <87zjauatbt.fsf@x220.int.ebiederm.org>
References: <1418319385.9942.9.camel@redhat.com>
	<20141211174921.GH20012@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20141211174921.GH20012@ubuntumail> (Serge Hallyn's message of
	"Thu, 11 Dec 2014 17:49:21 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Alexander Larsson (alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>> I'm working on using container technology to sandbox desktop
>> applications, and I've run into an issue with abstract unix domain
>> sockets. Generally unix domain sockets work fine in a container
>> situation because they are naturally namespaced via the filesystem
>> namespace.
>> 
>> However, abstract socket addresses are global to the *network*
>> namespace. This means that if you need to share the host network
>> namespace (typically so you have full ip networking access) you can't
>> limit access to *any* service that listens to an abstract unix socket.
>> 
>> I don't particularly need to use abstract sockets, so it would be ok to
>> just disallow its use in the container. I've looked at using seccomp for
>> this, but it doesn't seem to help here, as it needs to dereference the
>> socket address to tell if its abstract or not.
>> 
>> Does anyone have any idea how to do this?
>
> You should be able to use recent apparmor or selinux.

Agreed.  If you are trying to firewall an application the lsm's are the
firewall mechanism we have.

If you are building an application from scratch I would tend to
recommend the use of privilege separation, and only allowing the
``privileged'' part of your application to setup network sockets.

To me one of the scaries things an application can have is a network
socket to the outside world.

Eric
