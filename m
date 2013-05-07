From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] Use CAP_SYS_RESOURCE as magic for escaping user
	namespaces.
Date: Tue, 07 May 2013 11:38:37 -0700
Message-ID: <87fvxy8wk2.fsf@xmission.com>
References: <1367913689-3423-1-git-send-email-Janne.Karhunen@gmail.com>
	<20130507171007.GB10806@austin.hallyn.com>
	<CAE=NcrakiaDPRXJTQz770JNcYw9xbBJcEfCHsap-MGhkT8z2gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAE=NcrakiaDPRXJTQz770JNcYw9xbBJcEfCHsap-MGhkT8z2gQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Janne Karhunen's message of "Tue, 7 May 2013 21:14:42 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Tue, May 7, 2013 at 8:10 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
>
>> Uh, I would say nack, and if you need this then a device
>> namespace allowing you to 'pass' devices similarly to how you
>> pass a physical nic to a child netns is a part of the answer.
>
> Hmm, 'slight' issue is that it does not really exist and that ns
> can not even be properly specified as functionality (we tried
> that earlier didn't we - everyone had different opinion on what
> that ns should really do).

So far it appears that we don't need a device namespace.  As for most
things the usual DAC permissions apply.

The exceptions that I am aware of where we need something extra are
cases where the device abstraction is simply insufficient and needs
to be improved.

You can pass real network devices between network namespaces.

>> Your goals are not 100% clear to me.  What is it about a user
>> namespace that you want?
>
> I'm trying to experiment with a system that has init_ns size
> of one tiny task and apart from that everything runs inside
> containers. Because of this I need a way to elevate rights
> of certain trusted applications inside user namespaces so
> that they could operate against things requesting rights
> from init ns.

It will never be acceptable for tasks in a user namespace to have
any rights outside of that user namespace.  Elevating rights is the
wrong model.

The model very much needs to be how do we make a device safe for use by
an unprivielged user.

Most devices you can allow access to users in a user namespace with a
simple chmod.

You will also have the problem of how do you mount filesystems.  Except
for tmpfs I don't think there are any writable filesystems mountable in
a mount namespace created by a user namespace.

Your goal does sound interesting however.

Eric
