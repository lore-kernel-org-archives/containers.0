From: "Tanaka, Thomas" <thomas.tanaka-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: Building a SECURE cointainer using Cgroups ?
Date: Mon, 13 Oct 2008 11:01:48 -0700
Message-ID: <0A97A441BFADC74EA1E299A79C69DF9212D3F6CA1B@orsmsx504.amr.corp.intel.com>
References: <0A97A441BFADC74EA1E299A79C69DF9212D3F6C9E2@orsmsx504.amr.corp.intel.com>
	<1223920496.29877.22.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1223920496.29877.22.camel@nimitz>
Content-Language: en-US
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
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Tanaka,
	Thomas" <thomas.tanaka-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Yes absolutely that is what I am trying to achieve.

> Is it possible to build a secure container by using cgroups? My goal
> is to achieve a file system namespace container that will limit the
> file system view given to a process similar to chroot does but of
> course has to be secure.

You'll have to be a bit more specific than that.  Do you want to make
absolutely sure that certain containers have absolutely no access to
certain fs namespaces?

-- Dave
