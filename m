From: Adam Richter <adam_richter2004-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bisected] linux-audit in linux-3.14-rc1+ possibly breaking Linux
	Containers
Date: Tue, 18 Feb 2014 02:33:21 -0800 (PST)
Message-ID: <1392719601.80660.YahooMailNeo@web160601.mail.bf1.yahoo.com>
References: <1392418582.19695.YahooMailNeo@web160606.mail.bf1.yahoo.com>
	<1392426949.59963.YahooMailNeo@web160601.mail.bf1.yahoo.com>
Reply-To: Adam Richter <adam_richter2004-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1392426949.59963.YahooMailNeo-Y4cG9sIVSDhal3a5i+KC+JEhsgyP+Z75VpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, again.

Just so everyone can be aware of this workaround, I want to pass along that Eric Paris was kind enough to respond to my report about certain Linux Containers not working in linux-3.14-rc1 and later releases, and informed me that passing "audit=0" on the kernel command line is a way of working around the problem for now (which I confirmed), and that they are working on a fix.

Adam
