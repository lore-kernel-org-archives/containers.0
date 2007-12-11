From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 2/2][NETNS][RFD] use dst_entries to retrieve the network
	namespace pointer
Date: Tue, 11 Dec 2007 10:31:34 -0700
Message-ID: <m1ir35yw7d.fsf@ebiederm.dsl.xmission.com>
References: <20071211131231.701104221@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071211131754.788346594@ICON-9-164-138-215.megacenter.de.ibm.com>
	<475EC229.8020605@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <475EC229.8020605-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Tue, 11
	Dec 2007 20:00:25 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: xemul-3ImXcnM4P+0@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> Daniel Lezcano wrote:
>> The objective we have is to remove the fl_net field from the struct flowi.
>> 
>> In the previous patch, we make the network namespace to go up to the
> dst_entry.
>> This patch makes an example in how we can use the dst_entry/rtable combined
> with
>> a container_of to retrieve the network namespace when we have the flowi
> parameter.
>> 
>> One restriction is we should pass always a flowi parameter coming from a
> struct
>> dst_entry.
> this is an obfuscation IMHO. You use rtable instead of flowi, so
> - rtable obtain flowi meaning and keeps original meaning
> - stack usage in increased
>
> So, for the case, I think it is better to have an additional parameter
> on IP route output path. (There is a device on the input one).

Sounds right, and for shared code as well.

The only reason I used flowi in my proof of concept implementation
is that it seemed to be a prebuilt structure for passing that kind of
thing so I could save a bit of pain by extending what already existed.

Eric
