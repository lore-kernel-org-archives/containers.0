From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 1/2] Track in-kernel when we expect	checkpoint/restart
	to work
Date: Fri, 10 Oct 2008 22:57:34 +0200
Message-ID: <48EFC1BE.5010300__11094.0591701821$1223672630$gmane$org@fr.ibm.com>
References: <20081009190405.13A253CB@kernel>
	<1223626834.8787.8.camel@localhost.localdomain>
	<48EF144D.1050906@fr.ibm.com> <20081010145934.GF11695@elte.hu>
	<48EF7211.2000303@cs.columbia.edu>
	<1223656489.10017.33.camel@localhost.localdomain>
	<1223656603.11830.50.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1223656603.11830.50.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Fri, 2008-10-10 at 18:34 +0200, Greg Kurz wrote:
>> This flag is weak... testing it gives absolutly no hint whether the
>> checkpoint may succeed or not. As it is designed now, a user can only be
>> aware that checkpoint is *forever* denied. I agree that it's only useful
>> as a "flexible CR todo list".
> 
> Cool, so everyone agrees the patch is useful!

Yes, definitively. It is a good idea.
