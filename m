From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] namespaces: introduce sys_hijack (v7)
Date: Thu, 1 Nov 2007 22:52:20 -0700
Message-ID: <6599ad830711012252w5c8c29bbhd025e273ad5b5361@mail.gmail.com>
References: <20071024222125.GA8641@sergelap.austin.ibm.com>
	<20071031231359.GA5141@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071031231359.GA5141-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Oct 31, 2007 4:13 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
> Paul would like to be able to 'enter a cgroup', even if it is empty.
> Hijack takes more than just the nsproxy from the hijacked task, so
> this would result in different behavior between hijacking a populated
> cgroup and an empty cgroup.  So we might want to introduce a third
> type of hijacking, so we have HIJACK_PID, HIJACK_CGROUP, and
> HIJACK_EMPTY_CGROUP.

Do we need all three distinctions? If there was a process in the
cgroup, you could just use HIJACK_PID to hijack it. So HIJACK_CGROUP
could just do what you're currently calling HIJACK_EMPTY_CGROUP.

>
> It also then acts like the nsproxy cgroup patchset I sent out months
> ago for simply entering namespaces.  In fact this would need to be
> restricted to ns cgroups, and ns cgroups would need to grab a reference
> to the nsproxy.

Doesn't the nsproxy cgroup already grab an nsproxy reference?

>
> So do we want to allow hijacking/entering an empty cgroup?

In general, entering an emtpy cgroup is a perfectly fine thing to do -
it's only the ns_proxy case where this is complicated, since some
namespaces aren't safe against third-party changes to the task's
ns_proxy.

There really should be some way to enter such a set of namespaces, and
doing it at fork time pretty much has to be safe since that's when
nsproxy changes normally occur. Being able to do it at other times
(maybe only operating on current?) would be nice too.

Paul
