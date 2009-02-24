From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Deny external checkpoint unless frozen
Date: Tue, 24 Feb 2009 10:38:07 -0800
Message-ID: <1235500687.26788.260.camel@nimitz>
References: <20090221201317.GB13532@us.ibm.com>
	<20090223230438.GA2590@us.ibm.com> <1235435947.26788.216.camel@nimitz>
	<20090224010945.GA4797@us.ibm.com> <1235438283.26788.219.camel@nimitz>
	<20090224183116.GA21891@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224183116.GA21891-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-02-24 at 12:31 -0600, Serge E. Hallyn wrote:
> Well the patch is mainly on top of your patchset which defines
> the string holding reasons for uncheckpointability, right?  I
> assume you've modified that since then (too bad we're on a
> patch model at the moment) so seems easiest for you to toss it
> on top of your set.
> 
> Or you can send your latest version and I (or Suka) can write
> the /proc/$$/checkpointable file.

What I have so far is actually only for fds and uses /proc/$$/fdinfo/*.
I haven't done the per-task file yet.

-- Dave
