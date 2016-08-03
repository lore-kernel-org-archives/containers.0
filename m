From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] locks: Filter /proc/locks output on proc pid ns
Date: Wed, 03 Aug 2016 12:35:39 -0500
Message-ID: <8760rhiwlw.fsf@x220.int.ebiederm.org>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470209710-30022-1-git-send-email-kernel@kyup.com>
	<1470232012.18285.4.camel@poochiereds.net> <57A1FCE5.3040206@kyup.com>
	<57A205BE.3070202@virtuozzo.com> <57A20702.3040805@kyup.com>
	<20160803150631.GA3789@fieldses.org> <57A2097C.7060206@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <57A2097C.7060206-6AxghH7DbtA@public.gmane.org> (Nikolay Borisov's message of "Wed, 3
	Aug 2016 18:10:52 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> On 08/03/2016 06:06 PM, J. Bruce Fields wrote:
>> Digging around...  Oh, I see, there's an optional 'lock:..' line in
>> /proc/[pid]/fdinfo/[pid] file, is that what you're looking at?  I'd
>> forgotten.  Yeah, maybe that would make more sense long term.
>
> Yep, that's the one but this requires the userspace to be updated to use
> that interface. In the meantime we could do away with some maintenance
> of the existing /proc/locks :)

I am tempted to say let's not change /proc/locks at all, but if locks
really are in a pid namespace than I do think it makes sense to filter
them in /proc just so there is not excessive visiblity outside of the
pid namespace.

Excessive visibility is a problem on it's own.

Eric
