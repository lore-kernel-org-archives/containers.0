From: =?iso-2022-jp?B?GyRCP1w6ak0tOS8bKEI=?= <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>
Subject: BMC (Bare-Metal Container) is relased
Date: Fri, 11 Nov 2016 06:54:13 +0000
Message-ID: <TYXPR01MB08135B40DAAE84338AC9F7A7BDBB0@TYXPR01MB0813.jpnprd01.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Language: ja-JP
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
Cc: bmc <bmc-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

We released BMC (Bare-Metal Container) which runs a container (Docker)
image with a suitable Linux kernel on a remote physical machine.
BMC allows to change the kernel and its settings for the container
(Docker) image. As a result, the application extracts the full
performance of the physical machine.

A pre-built BMC image using DIND (Docker in Docker) technique is
offered. Users can avid burdensome setting up (ex. Apache CGI, etc).
We strongly recommend new users to try this pre-built version.

Pre-built BMC Doceker Image https://hub.docker.com/r/baremetalcontainer/bmc/
Source Code: https://github.com/baremetalcontainer/bmc
Official HP: http://www.itri.aist.go.jp/cpc/research/bmc/

BMC is exhibited at the Super Computing 2016 (AIST booth 1709) held at
Salt Lake City next week (Nov/14-17).
  http://sc16.supercomputing.org

The detail of BMC will be presented at IEEE HPCC (High Performance
Computing and Communication) 2016 (Dec/12-14) held at Sydney.
  http://www.swinflow.org/confs/2016/hpcc/

-----------
Kuni Suzaki
