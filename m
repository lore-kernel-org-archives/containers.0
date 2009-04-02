From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 24/29] c/r: Add CR_COPY() macro (v4)
Date: Thu, 02 Apr 2009 12:00:49 -0700
Message-ID: <87vdpmnan2.fsf@caffeine.danplanet.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-25-git-send-email-orenl@cs.columbia.edu>
	<20090401232013.GA31361@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090401232013.GA31361-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed, 1 Apr 2009 18:20:13 -0500")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

>> +
>> +/*
>> + * Copy @count items from @LIVE to @SAVE if op is CR_CPT (otherwise,
>> + * copy in the reverse direction)
>> + */
>> +#define CR_COPY_ARRAY(op, SAVE, LIVE, count)				\
>> +	do {								\
>> +		BUILD_BUG_ON(sizeof(*SAVE) != sizeof(*LIVE));		\
>> +		if (op == CR_CPT)					\
>> +			memcpy(SAVE, LIVE, count * sizeof(*SAVE));	\
>> +		else							\
>> +			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
>> +	} while (__must_be_array(SAVE) && __must_be_array(LIVE) && 0)

SH> It doesn't really matter I guess, but I'd prefer to see:

SH> #define CR_COPY_ARRAY(op, SAVE, LIVE, count)				\
SH> 	do {								\
SH> 		__must_be_array(SAVE);					\
SH> 		__must_be_array(LIVE);					\
SH> 		BUILD_BUG_ON(sizeof(*SAVE) != sizeof(*LIVE));		\
SH> 		if (op == CR_CPT)					\
SH> 			memcpy(SAVE, LIVE, count * sizeof(*SAVE));	\
SH> 		else							\
SH> 			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
SH> 	} while (0)

SH> Putting the __must_be_array()s inside the condition seems really weird.

I thought I explained this somewhere.  You'll get a compile warning if
you make __must_be_array() a statement without an lvalue.  If you try
to stuff the result into a variable that you don't use, you'll get a
warning about an unused variable.  I did what I did because it seemed
like a sane way to sidestep both of those issues.

Maybe a comment is warranted? :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
