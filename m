From: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Use CAP_SYS_RESOURCE as magic for escaping user
	namespaces.
Date: Wed, 8 May 2013 09:26:21 +0300
Message-ID: <CAE=NcratxHJ1dzDVn3qNxTagcA+CWi4PM+0_sx-9HTBZH_ym_w@mail.gmail.com>
References: <1367913689-3423-1-git-send-email-Janne.Karhunen@gmail.com>
	<20130507171007.GB10806@austin.hallyn.com>
	<CAE=NcrakiaDPRXJTQz770JNcYw9xbBJcEfCHsap-MGhkT8z2gQ@mail.gmail.com>
	<87fvxy8wk2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fvxy8wk2.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 7, 2013 at 9:38 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:

> So far it appears that we don't need a device namespace.  As for most
> things the usual DAC permissions apply.

Serge, please note ;)


> The exceptions that I am aware of where we need something extra are
> cases where the device abstraction is simply insufficient and needs
> to be improved.
>
> You can pass real network devices between network namespaces.

Have you considered passing things like frame buffer, input subsystem
and/or modem(s)?


>>> Your goals are not 100% clear to me.  What is it about a user
>>> namespace that you want?
>>
>> I'm trying to experiment with a system that has init_ns size
>> of one tiny task and apart from that everything runs inside
>> containers. Because of this I need a way to elevate rights
>> of certain trusted applications inside user namespaces so
>> that they could operate against things requesting rights
>> from init ns.
>
> It will never be acceptable for tasks in a user namespace to have
> any rights outside of that user namespace.  Elevating rights is the
> wrong model.

As ideal goal you're fully right, but given that init_ns size is almost
non-existent do you think that it is realistic to expect that no one
ever needs elevated rights within the container?

So all in all, I'm trying to make things work for real and complete
Linux systems since if this is done right, I think it is possible that
in the long run distributions start to default to running everything
inside container. If there is no privilege escalation possibility at all,
you just ruled out a huge bunch of existing configuration/etc tools
and for the next 5+ years, devices and kernel features.

For me containers are not so much a security feature but rather
a functional one.


> The model very much needs to be how do we make a device safe for use by
> an unprivielged user.
>
> Most devices you can allow access to users in a user namespace with a
> simple chmod.
>
> You will also have the problem of how do you mount filesystems.  Except
> for tmpfs I don't think there are any writable filesystems mountable in
> a mount namespace created by a user namespace.
>
> Your goal does sound interesting however.

Great to hear you agreed on the goal.


--
Janne
