From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cgroups: strcpy destination string overflow
Date: Tue, 5 Oct 2010 12:50:41 -0700
Message-ID: <AANLkTi=W7-aA1kG7-BQf7j0Yoykb2fY0gnLyQXsz1JMK__44233.1350678161$1286308275$gmane$org@mail.gmail.com>
References: <cover.1286193571.git.EXT-Eugeny.Kuznetsov@nokia.com>
	<2acb25707f916de866aa520b1a9f04f0f48c949c.1286193571.git.EXT-Eugeny.Kuznetsov@nokia.com>
	<20101005124802.989f6214.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101005124802.989f6214.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, Evgeny Kuznetsov <EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 5, 2010 at 12:48 PM, Andrew Morton
<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> On Tue, =A05 Oct 2010 12:38:05 +0400
> Evgeny Kuznetsov <EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org> wrote:
>
>> From: Evgeny Kuznetsov <ext-eugeny.kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
>>
>> Function "strcpy" is used without check for maximum allowed source
>> string length and could cause destination string overflow.
>> Check for string length is added before using "strcpy".
>> Function now is return error if source string length is more than
>> a maximum.
>>
>> Signed-off-by: Evgeny Kuznetsov <EXT-Eugeny.Kuznetsov-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
>> ---
>> =A0kernel/cgroup.c | =A0 =A02 ++
>> =A01 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index c9483d8..82bbede 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -1883,6 +1883,8 @@ static int cgroup_release_agent_write(struct cgrou=
p *cgrp, struct cftype *cft,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
const char *buffer)
>> =A0{
>> =A0 =A0 =A0 BUILD_BUG_ON(sizeof(cgrp->root->release_agent_path) < PATH_M=
AX);
>> + =A0 =A0 if (strlen(buffer) >=3D PATH_MAX)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> =A0 =A0 =A0 strcpy(cgrp->root->release_agent_path, buffer);
>
> I don't think this can happen, because cftype.max_write_len is
> PATH_MAX.

Yes, it shouldn't be possible.

>
> But it's pretty unobvious if this is actually true, and the code is
> fragile against future changes.

Fair enough - adding the check doesn't hurt anything.

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
