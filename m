From: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Subject: allocate specific port range for container?
Date: Tue, 5 Nov 2013 11:37:22 -0800 (PST)
Message-ID: <1383680242.61814.YahooMailNeo@web184303.mail.ne1.yahoo.com>
Reply-To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Hello LXC experts:

Is it possible to allocate specific transport port range for the socket bas=
ed applications inside one container?=A0

Say I have two containers: LXC_a and LXC_b, and each has some socket based =
applications I cannot modify or have no source code. If I need port range 5=
0000 - 51000 for LXC_a and 60000 - 61000 for LXC_b. Any way to achieve this?

The /proc/sys/net/ipv4/ip_local_port_range is for the host to adjust the ep=
hemeral port range, and we do not have the per LXC based setting on the loc=
al_port_range. Is this due to that the LXC network namespace isolation is a=
t the L3 level? How could I achieve this per port range LXC?

Regards,
-HB
