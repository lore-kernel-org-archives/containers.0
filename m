From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] C/R: simplify checkpoint debugging
Date: Mon, 22 Jun 2009 14:07:31 -0700
Message-ID: <8763eo6kq4.fsf@caffeine.danplanet.com>
References: <m33a9st5yk.fsf@pobox.com> <20090622204059.GB5537@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090622204059.GB5537-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Mon\, 22 Jun 2009 15\:40\:59 -0500")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

SH> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>> To enable printing of checkpoint/restart messages, one must enable
>> CHECKPOINT_DEBUG and boot with ckpt_debug= ... something I haven't
>> been able to figure out.  Further complicating matters is that if
>> DYNAMIC_DEBUG is enabled, you still won't get any debugging output
>> unless you manually enable debug output for all the functions you're
>> interested in via <debugfs>/dynamic_debug/control.  At this stage of
>> development most users will want all C/R messages either on or off and
>> don't need a fancy filtering mechanism.
>> 
>> Change ckpt_debug to print messages if CHECKPOINT_DEBUG=y.  Otherwise
>> it will emit nothing.  Remove ckpt_debug= setup code.  Reword
>> CHECKPOINT_DEBUG config help text appropriately.
>> 
>> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

SH> Yes please!

Enthusiastically seconded.  Or thirded, or whatever it would be.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
