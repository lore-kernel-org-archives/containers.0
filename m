From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroup : add clone_children control file
Date: Tue, 7 Sep 2010 13:26:48 -0700
Message-ID: <AANLkTi=zsT4=YZgpu5x9xtgskoTCjgTq+Vt6wh-8QtB=@mail.gmail.com>
References: <1283585466-30265-1-git-send-email-daniel.lezcano@free.fr>
	<AANLkTi=hM66-F-U2-ZoiDgksh51hq3MLb5aSLmwsShwi@mail.gmail.com>
	<4C869F48.9050603@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C869F48.9050603-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 7, 2010 at 1:23 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>> This bit is awkward - you're storing the original value of the
>> clone_children flag to report in the mount options, but this isn't
>> necessarily the current state. Might it be better to not store this
>> and just report the current value of the root cgroup's
>> CGRP_CLONE_CHILDREN flag?
>>
>
> Sure. Shall I do the same as the release agent mount option ?

I think so - the slight problem with this new flag is that it's
possible for the root cgroup to have one setting for clone_children
and all its children to have a different setting. But I guess we can
live with that. (Or maybe simply not make the default clone_children
value a mount option, but require it to be set on the root cgroup
after mounting?)

Paul
