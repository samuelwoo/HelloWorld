function init() {
  $('#date').prop('min', function(){
    return new Date().toJSON().split('T') [0];
  });

  $('#pay').click(pay);
}

/* UI helpers */

function showLoading() {
  $('#loading').show();
}

function hideLoading() {
  $('#loading').hide();
}

function dataTHead() {
  var thead = $('<thead />');
  var tr = $('<tr />');

  ['PayPeriod', 'FirstName', 'LastName', 'AnnualSalary', 'SuperRate', 'GrossIncome', 'IncomeTax', 'NetIncome' , 'Super']
    .forEach(function(title) {
      var th = $('<th />');
      th.text(title);
      tr.append(th);
    });

  thead.append(tr);

  return thead;
}

function dataTBody(payPeriod, payslips) {
  var tbody = $('<tbody />');

  payslips.forEach(function(payslip) {
    var tr = $('<tr />');
    var td = null;

    // payPeriod
    td = $('<td />');
    td.text(payPeriod);
    tr.append(td);

    // firstName
    td = $('<td />');
    td.text(payslip.employeeDetails.firstName);
    tr.append(td);

    // lastName
    td = $('<td />');
    td.text(payslip.employeeDetails.lastName);
    tr.append(td);

    // AnnualSalary
    td = $('<td />');
    td.text(payslip.employeeDetails.annualSalary);
    tr.append(td);

    // SuperRate
    td = $('<td />');
    td.text([payslip.employeeDetails.superRate, '%'].join(''));
    tr.append(td);

    // GrossIncome
    td = $('<td />');
    td.text(payslip.employeePayslip ? payslip.employeePayslip.grossIncome : '');
    tr.append(td);

    // IncomeTax
    td = $('<td />');
    td.text(payslip.employeePayslip ? payslip.employeePayslip.incomeTax : '');
    tr.append(td);

    // NetIncome
    td = $('<td />');
    td.text(payslip.employeePayslip ? payslip.employeePayslip.netIncome : '');
    tr.append(td);

    // Super
    td = $('<td />');
    td.text(payslip.employeePayslip ? payslip.employeePayslip.super : '');
    tr.append(td);

    tbody.append(tr);
  });

  return tbody;
}

function dataTable(payPeriod, payslips) {
  var table = $('<table />');
  table.addClass('data');

  if (!payslips.length) {
    return table;
  }

  var thead = dataTHead();
  table.append(thead);

  var tbody = dataTBody(payPeriod, payslips);
  table.append(tbody);

  return table;
}

function updateTable(payPeriod, payslips) {
  var table = dataTable(payPeriod, payslips);
  $('.table').find('.data').remove();
  $('.table').append(table)
}

function getInputs() {
  var firstName = $('#firstName').val();
  var lastName = $('#lastName').val();
  var annualSalary = $('#annualSalary').val();
  var superRate = $('#superRate').val();
  var payPeriod = $('#payPeriod').val();

  if (!firstName || !lastName || !annualSalary || !superRate || !payPeriod) {
    return null;
  }
  else {
    return {
      firstName: firstName,
      lastName: lastName,
      annualSalary: annualSalary,
      superRate: superRate,
      payPeriod: moment(payPeriod).format('MM-YYYY')
    };
  }
}

function pay() {
  var inputs = getInputs();

  if (!inputs) {
    alert('Please input everything!');
    return;
  }

  $.post('/employee/pay', inputs)
    .done(function(data) {
      updateTable(inputs.payPeriod, data);
      hideLoading();
    })
    .fail(function (err) {
      alert(err.responseText);

      hideLoading();
    });

  showLoading();
}

// Start!

$(init);
