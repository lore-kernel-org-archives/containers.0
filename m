From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Tue, 20 Jun 2017 01:23:48 -0500
Message-ID: <20170620062347.GA8520@mail.hallyn.com>
References: <20170508181156.GA23112@mail.hallyn.com>
	<9f80188c-df03-066a-5dac-785cc711d064@linux.vnet.ibm.com>
	<20170613171818.GA9070@mail.hallyn.com>
	<74e490f3-3c47-abfa-86ae-0fa0d1ddb43a@linux.vnet.ibm.com>
	<20170613235521.GC15685@mail.hallyn.com>
	<ce471b11-e76a-25f3-eae8-eca30e7233af@linux.vnet.ibm.com>
	<20170615030543.GA8979@mail.hallyn.com>
	<f0df1914-bca2-31a0-cdba-df30d85d70b3@linux.vnet.ibm.com>
	<20170618221418.GA364@mail.hallyn.com>
	<e9720595-2cdc-4dd7-57e7-95b85896d4ac@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e9720595-2cdc-4dd7-57e7-95b85896d4ac-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Jun 18, 2017 at 09:13:28PM -0400, Stefan Berger wrote:
> Can  you adapt your test cases. I haven't tried them, but having
> them would be important.

branch nsfscaps of github.com/hallyn/ltp now has a patch on top
which makes it work with your capabilities.  Tests are passing.

thanks,
-serge
