From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] fix checkpoint header exports
Date: Fri, 19 Jun 2009 23:34:03 -0500
Message-ID: <m3ljnnfrr8.fsf@pobox.com>
References: <m37hze2ib6.fsf@pobox.com> <20090620011005.GA3890@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090620011005.GA3890-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Fri\, 19 Jun 2009 18\:10\:05 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> Nathan Lynch [ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org] wrote:
> | checkpoint_types.h is not useful to userspace.  Unexport it.
>
> Hmm, I get this error when compiling ckpt-v16-dev when compiling for x86
>
> home/suka/containers/build/linux-cr/usr/include/linux/fs.h:11: included
> file 'linux/checkpoint_types.h' is not exported

Sorry.  I neglected to run make headers_check with this change, which
would have caught this.  Will fix this soon -- you can add
checkpoint_types.h back to headers-y to work around this, I think.
