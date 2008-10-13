From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: RE: Building a SECURE cointainer using Cgroups ?
Date: Mon, 13 Oct 2008 11:25:41 -0700
Message-ID: <1223922341.29877.29.camel@nimitz>
References: <0A97A441BFADC74EA1E299A79C69DF9212D3F6C9E2@orsmsx504.amr.corp.intel.com>
	<1223920496.29877.22.camel@nimitz>
	<0A97A441BFADC74EA1E299A79C69DF9212D3F6CA1B@orsmsx504.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <0A97A441BFADC74EA1E299A79C69DF9212D3F6CA1B-osO9UTpF0UQ64kNsxIetb7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Tanaka, Thomas" <thomas.tanaka-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-10-13 at 11:01 -0700, Tanaka, Thomas wrote:
> Yes absolutely that is what I am trying to achieve.

I'm going to put on my Serge hat and bet that you can do it with
security modules. :)

There's nothing that cgroups or containers gives you that will help with
your problem.  We actually haven't touched the fs namespaces at all, yet
because they work great as they stand today.

-- Dave
