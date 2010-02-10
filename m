From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 5/6][cr-test][v2]: eclone-5: nr_pids must not exceed
	nesting level
Date: Tue, 9 Feb 2010 17:28:31 -0800
Message-ID: <20100210012831.GA20795@us.ibm.com>
References: <20100209193331.GB30005@us.ibm.com>
	<20100209193619.GD32274@us.ibm.com>
	<20100209211705.GA32631@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100209211705.GA32631-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| > 
| > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > Date: Mon, 1 Feb 2010 18:13:51 -0800
| > Subject: [PATCH 5/6] eclone-5: nr_pids must not exceed nesting level
| > 
| > Verify that eclone() fails if nr_pids exceeds the current nesting level
| > of pid namespaces. Also verify that eclone() succeeds in choosing a pid
| > for a process in a descendant pid namespace.
| 
| This is a bit of a shame - it failed for me at first because I was
| running it inside a container.  But there is no way for a task to
| know it's own nsdepth right?

Nope - or at least I don't know of any way.

We could modify the test to set nr_pids to a ridiculously large value
just to test that eclone() fails when nr_pids exceeds nesting level.

| 
| So I went ahead and pushed these tests (plus a few changes).

Thanks,

Sukadev
