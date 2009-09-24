From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] ckptinfo.py: revert
	commit	8f99ace6513f958d572ef690d7af111991124f5c
Date: Thu, 24 Sep 2009 01:44:48 -0400
Message-ID: <4ABB0750.9090707@librato.com>
References: <1253665010-3472-1-git-send-email-orenl@librato.com>
	<20090923215343.GB6876@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090923215343.GB6876-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Tue, Sep 22, 2009 at 08:16:50PM -0400, Oren Laadan wrote:
>> Said commit "slightly" broke 'ckptinfo -ve', causing it to produce
>> only "--UNKNOWN--" objects.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> This one's my fault. In case you haven't already applied the reverted patch...
> I've got an alternate solution rolled in with my "extract kernel
> headers" branch which I should be able to post after I get the epoll
> patches posted.
> 
> Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

It's in ckpt-v18. Improvements always welcome :)

Oren.

> 
>> ---
>>  ckptinfo.py |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/ckptinfo.py b/ckptinfo.py
>> index add73cb..1c98569 100755
>> --- a/ckptinfo.py
>> +++ b/ckptinfo.py
>> @@ -42,7 +42,7 @@ char *%s_to_str(int type)
>>  	switch (type) {
>>  """ % type
>>      for key in list:
>> -        print "#ifdef CKPT_%s\n\tcase CKPT_%s: return \"%s\";\n#endif" % (key, key, key)
>> +        print "\tcase CKPT_%s: return \"%s\";\n" % (key, key)
>>
>>      print """
>>  	}
>> -- 
>> 1.6.0.4
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
